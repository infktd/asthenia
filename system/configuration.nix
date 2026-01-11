{ config, lib, pkgs, inputs, ... }:

let
  customFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
  ];

  myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
in
# =============================================================================
# SYSTEM CONFIGURATION
# =============================================================================
# This file manages system-wide NixOS settings. User-level configurations
# are managed separately via standalone Home Manager (home-manager switch).
#
# CONFIGURATION PHILOSOPHY:
# - System level: Core OS, services, hardware, system-wide programs
# - User level (Home Manager): Dotfiles, user applications, themes
#
# For niri/DMS: System provides session infrastructure (login, systemd services),
# user provides configuration files and appearance settings.
# =============================================================================
{
  imports = [
    # Home Manager is managed separately via standalone configuration.
    # Run: home-manager switch --flake .#niri
    # (Home Manager nixosModule integration removed to enable full feature set)
  ];

  # =============================================================================
  # HOME MANAGER (Standalone)
  # =============================================================================
  # Home Manager configurations are managed independently via:
  #   home-manager switch --flake .#niri
  #
  # This separation provides:
  # - Full access to all Home Manager options
  # - Independent user config updates (no sudo required)
  # - Per-user customization
  #
  # Home Manager configs located at:
  #   home/wm/niri/        - Niri window manager user config
  #   home/shared/         - Shared user config (all profiles)
  #   home/programs/       - Individual program configurations
  # =============================================================================

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };


  # Kernel parameters
  boot.kernelParams = [ "processor.max_cstate=1" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking = {
    hostName = "arasaka";
    networkmanager.enable = true;
  };

  # Timezone and locale
  time.timeZone = "America/Chicago";
  
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
  users.users.infktd = {
    isNormalUser = true;
    description = "infktd";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    pcscliteWithPolkit
    home-manager  # Required for standalone Home Manager usage
  ];

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # PCSCD (Smartcard Support)
  services.pcscd = {
    enable = true;
  };

  # Making fonts accessible to applications
  fonts.packages = with pkgs; [
    font-awesome
  ] ++ customFonts;

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
