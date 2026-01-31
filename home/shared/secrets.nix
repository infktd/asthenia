# =============================================================================
# SECRETS MANAGEMENT (sops-nix)
# =============================================================================
# Manages encrypted secrets using sops with age encryption
#
# HOW IT WORKS:
# - Secrets are encrypted in secrets/secrets.yaml (committed to git)
# - Age private key lives at ~/.config/sops/age/keys.txt (NOT in git)
# - At home-manager activation, secrets are decrypted to ~/.config/sops-nix/secrets/
# - Symlinks point from target locations (e.g., ~/.ssh/id_ed25519) to decrypted files
#
# SETUP (one-time per machine):
# 1. Generate age key: age-keygen -o ~/.config/sops/age/keys.txt
# 2. Get public key: age-keygen -y ~/.config/sops/age/keys.txt
# 3. Add public key to .sops.yaml
# 4. Store private key in Bitwarden for new machine setup
#
# ADDING NEW SECRETS:
# 1. Define secret in this file under sops.secrets
# 2. Add to secrets/secrets.yaml: sops secrets/secrets.yaml
# 3. Run home-manager switch
# =============================================================================
{ config, lib, pkgs, isDarwin ? false, ... }:

let
  # Home directory varies by platform
  homeDir = if isDarwin then "/Users/jayne" else "/home/infktd";
in
{
  # ---------------------------------------------------------------------------
  # SOPS CONFIGURATION
  # ---------------------------------------------------------------------------
  sops = {
    # Age key location (same on all machines, transferred via Bitwarden)
    age.keyFile = "${homeDir}/.config/sops/age/keys.txt";

    # Default location for decrypted secrets
    # home-manager sops decrypts to XDG runtime or config dir
    defaultSopsFile = ../../secrets/secrets.yaml;

    # ---------------------------------------------------------------------------
    # SECRET DEFINITIONS
    # ---------------------------------------------------------------------------
    secrets = {
      # SSH private key - decrypted to ~/.ssh/id_ed25519
      ssh_private_key = {
        path = "${homeDir}/.ssh/id_ed25519";
        mode = "0600";
      };

      # GPG private key - decrypted for import into keyring
      gpg_private_key = {
        mode = "0600";
      };

      # GitHub personal access token for gh CLI
      github_token = {
        mode = "0600";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # SSH DIRECTORY SETUP
  # ---------------------------------------------------------------------------
  # Ensure .ssh directory exists with correct permissions
  home.file.".ssh/.keep" = {
    text = "";
    onChange = ''
      chmod 700 ${homeDir}/.ssh
    '';
  };

  # SSH public key (not secret, can be in nix config directly)
  home.file.".ssh/id_ed25519.pub" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDEFYmeqqq5vHaFcogUQNomFcDeVTawvA98o5rh8GsJ 25016104+infktd@users.noreply.github.com\n";
    onChange = ''
      chmod 644 ${homeDir}/.ssh/id_ed25519.pub
    '';
  };

  # ---------------------------------------------------------------------------
  # GPG KEY IMPORT
  # ---------------------------------------------------------------------------
  # Import GPG key into keyring on activation
  home.activation.importGpgKey = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    if [ -f "${config.sops.secrets.gpg_private_key.path}" ]; then
      ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets.gpg_private_key.path} 2>/dev/null || true
      # Trust the key ultimately
      echo "D59E0A93917AD728A9EBBC025C39B8FCD1521E8E:6:" | ${pkgs.gnupg}/bin/gpg --import-ownertrust 2>/dev/null || true
    fi
  '';

  # ---------------------------------------------------------------------------
  # GITHUB CLI TOKEN SETUP
  # ---------------------------------------------------------------------------
  # Authenticate gh CLI with the token from secrets
  home.activation.setupGhToken = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    if [ -f "${config.sops.secrets.github_token.path}" ]; then
      TOKEN=$(cat ${config.sops.secrets.github_token.path})
      mkdir -p ${homeDir}/.config/gh
      echo "$TOKEN" | ${pkgs.gh}/bin/gh auth login --with-token 2>/dev/null || true
    fi
  '';
}
