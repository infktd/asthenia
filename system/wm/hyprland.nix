# =============================================================================
# HYPRLAND SYSTEM CONFIGURATION
# =============================================================================
# System-level configuration for Hyprland window manager.
#
# This module provides:
# - Hyprland compositor with XWayland support
# - Essential system services (pipewire, bluetooth, polkit)
# - Display manager (greetd) with tuigreet
# - XDG portals with Hyprland-specific integration
# - System packages for Wayland development
#
# Key differences from niri.nix:
# - No DMS (Dank Material Shell) integration
# - Uses xdg-desktop-portal-hyprland for better Hyprland integration
# - Simplified polkit setup without DMS systemd dependencies
# =============================================================================

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
    inputs.hyprland.nixosModules.hyprland
  ];

  # === PROGRAMS ===
  programs.dconf.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
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
          session = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland";
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
    enable = true;
    config.common.default = [ "hyprland" "gtk" ];
    extraPortals = with pkgs; [
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
}