{ pkgs, lib, ... }:

let
  username = "infktd";  # CHANGE THIS
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    # Generic Applications
    bottom      # System monitor (btm)
    dust        # Disk usage analyzer
    eza         # Modern ls replacement
    fd          # Modern find replacement
    ripgrep     # Fast grep alternative
    tree        # Directory tree viewer
    signal-desktop
    vlc
    yubioath-flutter
    
    # File Management
    unzip
    zip
    
    # Development tools
    git

    # Languages
    python3
    nodejs

  ];
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

    stateVersion = "24.11";  # Set this to your NixOS version

    sessionVariables = {
      EDITOR = "vim";
    };
  };

    

    # Restart systemd services on change
    systemd.user.startServices = "sd-switch";
}
