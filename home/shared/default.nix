{ pkgs, lib, ... }:

let
  username = "infktd";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";
  
  # Custom scripts
  scripts = pkgs.callPackage ../scripts { };

  packages = with pkgs; [
    # Generic Applications
    bottom      # System monitor (btm)
    dust        # Disk usage analyzer
    eza         # Modern ls replacement
    fd          # Modern find replacement
    ripgrep     # Fast grep alternative
    tree        # Directory tree viewer
    bolt-launcher
    signal-desktop
    vlc
    yubioath-flutter

    # User Shell packages
    xorg.xhost
    
    # File Management
    unzip
    zip
    
    # Development tools
    git

    # Languages
    python3
    nodejs
  ] ++ (lib.attrValues (lib.filterAttrs (n: v: !lib.isFunction v) scripts));
in
{
  programs.home-manager.enable = true;

  imports = [
    ../themes
    ./programs.nix
    ./services.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory packages;

    stateVersion = "24.11";  # Don't change this after initial install

    sessionVariables = {
      EDITOR = "vim";
    };
  };

    

    # Restart systemd services on change
    systemd.user.startServices = "sd-switch";
}
