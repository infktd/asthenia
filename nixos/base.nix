# All shared NixOS config: boot, locale, nix, networking, audio, packages, containers, users, sops
{ config, lib, pkgs, ... }: {

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "processor.max_cstate=1" "nokaslr" ];
    loader = { efi.canTouchEfiVariables = true; systemd-boot.enable = true; };
    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; "fs.inotify.max_user_instances" = 524288; };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = builtins.listToAttrs
    (map (k: { name = k; value = "en_US.UTF-8"; }) [
      "LC_ADDRESS" "LC_IDENTIFICATION" "LC_MEASUREMENT" "LC_MONETARY"
      "LC_NAME" "LC_NUMERIC" "LC_PAPER" "LC_TELEPHONE" "LC_TIME"
    ]);
  time.timeZone = "America/Chicago";

  nix = {
    gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; };
    package = pkgs.nixVersions.latest;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" "https://asthenia.cachix.org" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "asthenia.cachix.org-1:XgoFA0Dx9EB00nXiJn82LSUVn2iko0L5o62gkm4x6aw="
      ];
    };
  };

  networking = { firewall.enable = true; networkmanager.enable = true; };
  services.avahi.enable = true;
  services.openssh = { enable = true; settings = { PasswordAuthentication = true; PermitRootLogin = "no"; }; };
  services.tailscale = { enable = true; authKeyFile = "/run/secrets/tailscale_auth_key"; };

  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true;
    raopOpenFirewall = true;
    extraConfig.pipewire."10-airplay"."context.modules" = [{ name = "libpipewire-module-raop-discover"; }];
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    curl devenv dive docker docker-compose git home-manager
    pcscliteWithPolkit podman-tui vim wget
  ];
  fonts.packages = with pkgs; [ font-awesome ] ++ (with nerd-fonts; [ jetbrains-mono iosevka fira-code ]);
  programs.nix-ld = { enable = true; libraries = pkgs.steam-run.args.multiPkgs pkgs; };
  programs.zsh.enable = true;
  services.pcscd.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true; dockerCompat = true; dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  users.users.infktd = {
    description = "infktd";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "docker" ];
    isNormalUser = true; shell = pkgs.zsh;
  };

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/home/infktd/.config/sops/age/keys.txt";
    secrets.tailscale_auth_key = {};
  };

  system.stateVersion = "24.11";
}
