# =============================================================================
# GIT AND GITHUB CLI CONFIGURATION
# =============================================================================
# Git version control with GPG commit signing and GitHub CLI
# =============================================================================
{ lib, pkgs, isDarwin ? false, ... }:

let
  # GPG key ID for commit signing
  gpgKeyId = "5C39B8FCD1521E8E";

  # User identity
  userName = "infktd";
  userEmail = "25016104+infktd@users.noreply.github.com";
in
{
  # ---------------------------------------------------------------------------
  # GIT CONFIGURATION
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;

    # GPG commit signing
    signing = {
      key = gpgKeyId;
      signByDefault = true;
    };

    settings = {
      # User identity for commits
      user = {
        name = userName;
        email = userEmail;
      };

      # Use SSH for GitHub
      url."git@github.com:".insteadOf = "https://github.com/";

      # Default branch name
      init.defaultBranch = "main";

      # Pull strategy
      pull.rebase = true;

      # Push behavior
      push.autoSetupRemote = true;

      # Better diffs
      diff.colorMoved = "default";

      # Merge conflict style
      merge.conflictstyle = "diff3";

      # GPG program path
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };

  # ---------------------------------------------------------------------------
  # GITHUB CLI CONFIGURATION
  # ---------------------------------------------------------------------------
  xdg.configFile."gh/config.yml".force = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
    settings = {
      git_protocol = "ssh";
    };
  };
}
