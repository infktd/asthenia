# Core user config: identity, packages, secrets, services, themes
{ config, pkgs, lib, isDarwin ? false, ... }:

let
  username = if isDarwin then "jayne" else "infktd";
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  scripts = pkgs.callPackage ./scripts {};

  commonPackages = with pkgs; [
    obsidian
    claude-code git github-copilot-cli go nodejs opencode python3 bun
    age sops
    eza fd tree unzip zip
    bottom dust ripgrep
  ];

  linuxPackages = with pkgs; [
    bolt-launcher signal-desktop vlc yubioath-flutter
    vulkan-tools xdg-utils xhost
  ];
in
{
  programs.home-manager.enable = true;

  xdg = { configHome = "${homeDirectory}/.config"; enable = true; };

  home = {
    inherit username homeDirectory;
    packages = commonPackages
      ++ lib.optionals (!isDarwin) linuxPackages
      ++ (lib.attrValues (lib.filterAttrs (_: v: !lib.isFunction v) scripts));
    stateVersion = "24.11";
    sessionVariables.EDITOR = "nvim";
  };

  systemd.user.startServices = lib.mkIf (!isDarwin) "sd-switch";

  # Secrets (sops-nix)
  sops = {
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      ssh_private_key = { path = "${homeDirectory}/.ssh/id_ed25519"; mode = "0600"; };
      gpg_private_key = { mode = "0600"; };
      github_token = { mode = "0600"; };
    };
  };

  home.file.".ssh/.keep" = { text = ""; onChange = ''chmod 700 ${homeDirectory}/.ssh''; };
  home.file.".ssh/id_ed25519.pub" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDEFYmeqqq5vHaFcogUQNomFcDeVTawvA98o5rh8GsJ 25016104+infktd@users.noreply.github.com\n";
    onChange = ''chmod 644 ${homeDirectory}/.ssh/id_ed25519.pub'';
  };

  home.activation.importGpgKey = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    if [ -f "${config.sops.secrets.gpg_private_key.path}" ]; then
      ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets.gpg_private_key.path} 2>/dev/null || true
      echo "D59E0A93917AD728A9EBBC025C39B8FCD1521E8E:6:" | ${pkgs.gnupg}/bin/gpg --import-ownertrust 2>/dev/null || true
    fi
  '';

  home.activation.setupGhToken = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    if [ -f "${config.sops.secrets.github_token.path}" ]; then
      TOKEN=$(cat ${config.sops.secrets.github_token.path})
      mkdir -p ${homeDirectory}/.config/gh
      echo "$TOKEN" | ${pkgs.gh}/bin/gh auth login --with-token 2>/dev/null || true
    fi
  '';

  services.gpg-agent = { enable = true; enableSshSupport = true; };

  # GTK themes (Linux only)
  gtk = lib.mkIf (!isDarwin) rec {
    enable = true;
    iconTheme = { name = "BeautyLine"; package = pkgs.beauty-line-icon-theme; };
    theme = { name = "Juno-ocean"; package = pkgs.juno-theme; };
    gtk4 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
      extraCss = ''@import url("file://${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk-dark.css");'';
    };
  };
}
