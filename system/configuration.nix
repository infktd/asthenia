{ config, lib, pkgs, inputs, vars, ... }:

let
  customFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
  ];

  myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
  
  # Import window manager module based on selection
  wmModule = 
    if vars.windowManager.selected == "niri" then
      ../home/wm/niri
    else if vars.windowManager.selected == "hyprland" then
      ../home/wm/hyprland
    else
      ../home/shared;  # Fallback to shared config without WM
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs vars; };
    backupFileExtension = "backup";
    users.${vars.user.username} = import wmModule;
  };

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = vars.system.hostname;
    networkmanager.enable = vars.network.networkManager;
  };

  # Timezone and locale
  time.timeZone = vars.locale.timeZone;
  
  i18n.defaultLocale = vars.locale.defaultLocale;
  
  i18n.extraLocaleSettings = {
    LC_ADDRESS = vars.locale.defaultLocale;
    LC_IDENTIFICATION = vars.locale.defaultLocale;
    LC_MEASUREMENT = vars.locale.defaultLocale;
    LC_MONETARY = vars.locale.defaultLocale;
    LC_NAME = vars.locale.defaultLocale;
    LC_NUMERIC = vars.locale.defaultLocale;
    LC_PAPER = vars.locale.defaultLocale;
    LC_TELEPHONE = vars.locale.defaultLocale;
    LC_TIME = vars.locale.defaultLocale;
  };

  # Audio configuration (PipeWire replaces PulseAudio and ALSA)
  services.pulseaudio.enable = false;
  security.rtkit.enable = vars.hardware.audio.enable;
  services.pipewire = {
    enable = vars.hardware.audio.enable && vars.hardware.audio.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User configuration
  users.users.${vars.user.username} = {
    isNormalUser = true;
    description = vars.user.fullName;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.bash;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
  ];

  # Making fonts accessible to applications
  fonts.packages = with pkgs; [
    font-awesome
  ] ++ customFonts;

  # Enable flakes
  nix = {
    package = pkgs.nixVersions.latest;
    
    settings = {
      experimental-features = if vars.advanced.experimentalFeatures then [ "nix-command" "flakes" ] else [ ];
      auto-optimise-store = true;
      
      # Trusted users for nix commands
      trusted-users = [ "root" "@wheel" ];
    };

    # Automatic garbage collection
    gc = {
      automatic = vars.advanced.autoGarbageCollect;
      dates = "weekly";
      options = "--delete-older-than ${toString vars.advanced.garbageCollectDays}d";
    };
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # System version
  system.stateVersion = "24.11"; # Don't change this after initial install
}
