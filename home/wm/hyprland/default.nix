# =============================================================================
# HYPRLAND HOME MANAGER CONFIGURATION
# =============================================================================
# User-level configuration for Hyprland window manager.
#
# This module provides:
# - NVIDIA-optimized environment variables for Wayland
# - Font and cursor configuration
# - Audio control utilities
# - XDG configuration file links for Hyprland and desktop components
# - Imports for all Hyprland-related program configurations
#
# Configuration files are managed in ./config/ directory and linked via XDG,
# following the same pattern as niri configuration.
# =============================================================================

{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib.file) mkOutOfStoreSymlink;

  nerdFonts = with (pkgs.nerd-fonts); [
    fira-code
    iosevka
    jetbrains-mono
  ];

  fontPkgs = with pkgs; [
    font-awesome
    material-design-icons
  ] ++ nerdFonts;

  audioPkgs = with pkgs; [
    paprefs
    pavucontrol
    playerctl
    pulsemixer
  ];

  packages = with pkgs; [
    brightnessctl
    grim
    libnotify
    nemo
    networkmanagerapplet
    rofi             # Application launcher (includes wayland support)
    slurp            # Screen region selector
    wl-clipboard
    xwayland-satellite-unstable
  ] ++ fontPkgs ++ audioPkgs;
in

{
  # === FONTS ===
  fonts.fontconfig.enable = true;

  # === HOME ===
  home.packages = packages;
  home.pointerCursor = {
    gtk.enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
  };
  home.sessionVariables = {
    # NVIDIA-specific Wayland optimizations
    CLUTTER_PAINT = "disable-clipped-redraws:disable-culling";
    CLUTTER_VBLANK = "none";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_ENABLE_WAYLAND = 1;
    NIXOS_OZONE_WL = 1;
    SHELL = "${lib.exe pkgs.zsh}";
    WLR_NO_HARDWARE_CURSORS = 1;
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = 0;
    __GL_THREADED_OPTIMIZATION = 1;
    __GL_VRR_ALLOWED = 0;
    __GL_YIELD = "NOTHING";
  };
  home.stateVersion = "24.11";

  # === IMPORTS ===
  imports = [
    ../../shared
    ../../programs/waybar
    ../../programs/mako
    ../../programs/hyprlock
    ../../programs/hypridle
    ../../programs/hyprpaper
  ];

  # === WAYLAND WINDOW MANAGER ===
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    extraConfig = import ./config/hyprland.nix;
  };

  # === XDG ===
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
    --disable-gpu-driver-bug-workarounds
  '';
}