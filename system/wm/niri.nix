{ pkgs, lib, inputs, ... }:

{
  # === ENVIRONMENT ===
  environment.systemPackages = with pkgs; [
    cage
    gamescope
    libsecret
    wayland-utils
    wl-clipboard
  ];

  # === HARDWARE ===
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # === IMPORTS ===
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.niri-flake.nixosModules.niri
  ];

  # === PROGRAMS ===
  programs.dconf.enable = true;
  programs.dms-shell = {
    enable = true;
    enableAudioWavelength = true;
    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # === SECURITY ===
  security.polkit.enable = true;

  # === SERVICES ===
  services.blueman.enable = true;
  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };
  services.gnome.gnome-keyring.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      tuigreet_session =
        let
          session = "${pkgs.niri-unstable}/bin/niri-session";
          tuigreet = "${lib.exe pkgs.tuigreet}";
        in
        {
          command = "${tuigreet} --time --remember --cmd ${session}";
          user = "greeter";
        };
      default_session = tuigreet_session;
    };
  };
  services.pipewire = {
    alsa.enable = true;
    alsa.support32Bit = true;
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.seatd.enable = true;

  # === SYSTEMD ===
  systemd.services.greetd.serviceConfig = {
    StandardError = "journal";
    StandardInput = "tty";
    StandardOutput = "tty";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
    Type = "idle";
  };
  systemd.user.services.dms = {
    wantedBy = lib.mkForce [ "niri.service" ];
  };
  systemd.user.services.niri-flake-polkit.enable = false;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    after = [ "graphical-session.target" ];
    description = "polkit-gnome-authentication-agent-1";
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
      Type = "simple";
    };
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
  };

  # === XDG ===
  xdg.portal = {
    config.common.default = [ "gtk" ];
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };
}
