{ pkgs, lib, vars, ... }:

let
  username = vars.user.username;
  homeDirectory = vars.user.homeDirectory;
  configHome = "${homeDirectory}/.config";
  
  # Custom scripts
  scripts = pkgs.callPackage ../scripts { };

  # Base packages
  basePackages = with pkgs; [
    # Generic Applications
    bottom      # System monitor (btm)
    dust        # Disk usage analyzer
    eza         # Modern ls replacement
    fd          # Modern find replacement
    ripgrep     # Fast grep alternative
    tree        # Directory tree viewer
    yubioath-flutter

    # User Shell packages
    xorg.xhost
    
    # File Management
    unzip
    zip
    
    # Development tools
    git
  ] ++ (lib.attrValues (lib.filterAttrs (n: v: !lib.isFunction v) scripts));
  
  # Development language packages
  devLanguages = with pkgs; lib.optionals vars.development.enable (
    lib.optional vars.development.languages.python python3 ++
    lib.optional vars.development.languages.nodejs nodejs ++
    lib.optional vars.development.languages.rust cargo ++
    lib.optional vars.development.languages.go go ++
    lib.optional vars.development.languages.java jdk
  );
  
  # Application packages
  appPackages = with pkgs; 
    lib.optional vars.applications.communication.signal signal-desktop ++
    lib.optional vars.applications.media.vlc vlc ++
    lib.optional vars.applications.media.mpv mpv ++
    lib.optional vars.applications.media.spotify spotify;
  
  packages = basePackages ++ devLanguages ++ appPackages;
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
