# Shared desktop services: greetd, bluetooth, pipewire, polkit, portals
{ pkgs, lib, ... }: {

  environment.systemPackages = with pkgs; [ cage gamescope libsecret wayland-utils wl-clipboard ];

  hardware.bluetooth = { enable = true; settings.General.Enable = "Source,Sink,Media,Socket"; };

  programs.dconf.enable = true;
  security.polkit.enable = true;

  services.blueman.enable = true;
  services.dbus = { enable = true; packages = [ pkgs.dconf ]; };
  services.gnome.gnome-keyring.enable = true;
  services.pipewire = {
    alsa.enable = true; alsa.support32Bit = true;
    enable = true; pulse.enable = true; wireplumber.enable = true;
  };
  services.seatd.enable = true;

  systemd.services.greetd.serviceConfig = {
    StandardError = "journal"; StandardInput = "tty"; StandardOutput = "tty";
    TTYReset = true; TTYVHangup = true; TTYVTDisallocate = true; Type = "idle";
  };
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    after = [ "graphical-session.target" ];
    description = "polkit-gnome-authentication-agent-1";
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure"; RestartSec = 1; TimeoutStopSec = 10; Type = "simple";
    };
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
  };
}
