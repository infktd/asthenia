{ config, lib, pkgs, inputs, ... }:

let
  customFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
    fira-code
  ];

  myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
in

{
  # === BOOT ===
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "processor.max_cstate=1" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  # === ENVIRONMENT ===
  environment.systemPackages = with pkgs; [
    curl
    devenv
    dive
    docker
    docker-compose
    git
    home-manager
    pcscliteWithPolkit
    podman-tui
    vim
    wget
  ];

  # === FONTS ===
  fonts.packages = with pkgs; [
    font-awesome
  ] ++ customFonts;

  # === I18N ===
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

  # === IMPORTS ===
  imports = [
  ];

  # === NETWORKING ===
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
  networking.hostName = "arasaka";
  networking.networkmanager.enable = true;

  # === NIX ===
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];

    # Binary caches for faster builds
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://asthenia.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "asthenia.cachix.org-1:XgoFA0Dx9EB00nXiJn82LSUVn2iko0L5o62gkm4x6aw="
    ];
  };

  # === PROGRAMS ===
  programs.nix-ld = {
    enable = true;
    libraries = pkgs.steam-run.args.multiPkgs pkgs;
  };
  programs.zsh.enable = true;

  # === SECURITY ===
  security.rtkit.enable = true;

  # === SERVICES ===
  services.avahi.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };
  services.pcscd.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    extraConfig.pipewire = {
      "10-airplay" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
          }
        ];
      };
    };
    pulse.enable = true;
    raopOpenFirewall = true;
  };
  services.pulseaudio.enable = false;
  services.tailscale = {
    enable = true;
    authKeyFile = "/run/secrets/tailscale_auth_key";
  };

  # === SOPS ===
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/home/infktd/.config/sops/age/keys.txt";
    secrets.tailscale_auth_key = {};
  };

  # === SYSTEM ===
  system.stateVersion = "24.11";

  # === TIME ===
  time.timeZone = "America/Chicago";

  # === USERS ===
  users.users.infktd = {
    description = "infktd";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "docker" ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # === VIRTUALISATION ===
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    defaultNetwork.settings.dns_enabled = true;
    dockerCompat = true;
    enable = true;
  };
}
