{ config, lib, pkgs, ... }:

let
  customFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
  ];

  myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
in
{


  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    networkmanager.enable = true;
  };

  # Timezone and locale
  time.timeZone = "America/Chicago";  # Change to your timezone
  
  i18n.defaultLocale = "en_US.UTF-8";
  
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Audio configuration (PipeWire replaces PulseAudio and ALSA)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User configuration
  users.users.infktd = {  # CHANGE THIS
    isNormalUser = true;
    description = "infktd";
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

  security = {
    # Sudo custom prompt message
    sudo.configFile = ''
      Defaults lecture=always
      Defaults lecture_file=${misc/groot.txt}
    '';
  };

  # Enable flakes
  nix = {
    package = pkgs.nixVersions.latest;
    
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      
      # Trusted users for nix commands
      trusted-users = [ "root" "@wheel" ];
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
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
