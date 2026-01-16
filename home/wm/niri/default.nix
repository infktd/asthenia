{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib.file) mkOutOfStoreSymlink;

  nerdFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
    fira-code
  ];

  fontPkgs = with pkgs; [
    font-awesome # awesome fonts
    material-design-icons # fonts with glyphs
  ] ++ nerdFonts;

  audioPkgs = with pkgs; [
    paprefs # pulseaudio preferences
    pavucontrol # pulseaudio volume control
    playerctl # music player controller
    pulsemixer # pulseaudio mixer
  ];

  packages = with pkgs; [
    brightnessctl # control laptop display brightness
    grim # screenshots
    libnotify # notifications
    nemo # file manager
    networkmanagerapplet # network manager systray app
    wl-clipboard # clipboard support
    xwayland-satellite-unstable # X11 app support for niri
  ] ++ fontPkgs ++ audioPkgs;
in
# =============================================================================
# NIRI USER CONFIGURATION (Home Manager)
# =============================================================================
# This file manages USER-LEVEL niri and desktop environment settings.
# System-level infrastructure is in system/wm/niri.nix
#
# WHAT BELONGS HERE (User Level):
# - Niri configuration files (KDL format in ./config/)
# - Session environment variables (Wayland, NVIDIA, performance)
# - User-specific packages (tools, fonts, audio controls)
# - Desktop appearance and behavior
#
# APPLIED VIA: home-manager switch --flake .#niri
# (NOT via nixos-rebuild - this is standalone Home Manager)
#
# RELATIONSHIP TO SYSTEM CONFIG:
# - System provides: niri-session binary, systemd services, login manager
# - User provides: config files, environment, appearance
# - Both work together: system starts session, user config customizes it
# =============================================================================
{
  # Import shared user configuration (base programs, themes, services)
  imports = [
    ../../shared
  ];

  # =============================================================================
  # DESKTOP APPEARANCE
  # =============================================================================
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  home = {
    inherit packages;
    stateVersion = "24.11";

    # =============================================================================
    # SESSION ENVIRONMENT VARIABLES
    # =============================================================================
    # These variables are set in the user's graphical session
    # Applied when niri-session starts (after login via greetd)
    sessionVariables = {
      # Wayland-specific settings
      NIXOS_OZONE_WL = 1;
      SHELL = "${lib.exe pkgs.zsh}";
      MOZ_ENABLE_WAYLAND = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      # NVIDIA + Wayland performance and compatibility
      __GL_GSYNC_ALLOWED = 0;
      __GL_VRR_ALLOWED = 0;
      WLR_NO_HARDWARE_CURSORS = 1;
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Aggressive performance tuning for NVIDIA
      __GL_YIELD = "NOTHING";
      __GL_THREADED_OPTIMIZATION = 1;
      CLUTTER_PAINT = "disable-clipped-redraws:disable-culling";
      CLUTTER_VBLANK = "none";
    };
  };

  # =============================================================================
  # FONTS
  # =============================================================================
  fonts.fontconfig.enable = true;

  # =============================================================================
  # NIRI CONFIGURATION FILES
  # =============================================================================
  # Modular KDL config files for niri compositor
  # Main config imports the other modules
  xdg.configFile."niri/config.kdl".source = ./config/config.kdl;
  xdg.configFile."niri/input.kdl".source = ./config/input.kdl;
  xdg.configFile."niri/keybindings.kdl".source = ./config/keybindings.kdl;
  xdg.configFile."niri/outputs.kdl".source = ./config/outputs.kdl;
  xdg.configFile."niri/layout.kdl".source = ./config/layout.kdl;
  xdg.configFile."niri/rules.kdl".source = ./config/rules.kdl;
  xdg.configFile."niri/workspaces.kdl".source = ./config/workspaces.kdl;

  # Electron app optimization for Wayland
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
    --disable-gpu-driver-bug-workarounds
  '';

  # =============================================================================
  # XDG PORTALS
  # =============================================================================
  # Portal registration is managed at system level (system/wm/niri.nix)
  # User-level portal configuration removed to avoid conflicts
  # System configuration provides:
  # - xdg-desktop-portal-gtk
  # - xdg-desktop-portal-gnome
  # - Default portal assignments
  # =============================================================================
}
