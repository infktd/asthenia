{ pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.niri-flake.nixosModules.niri
  ];
  
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    libsecret
    cage
    gamescope
  ];

  programs = {
    dconf.enable = true;
    niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };

  # XDG Desktop Portal for file pickers and other desktop integrations
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.common.default = [ "gtk" ];
  };

  # TTY service config for login
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services = {
    # Bluetooth manager
    blueman.enable = true;

    # GTK theme config
    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    # User's credentials manager
    gnome.gnome-keyring.enable = true;

    # Init session with niri
    greetd = {
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

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # Prerequisite for screensharing
      wireplumber.enable = true;
    };

    # Allows niri to run without root privileges
    seatd.enable = true;
  };
}
