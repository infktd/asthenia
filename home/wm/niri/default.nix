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
  ];

  # === XDG ===
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
    --disable-gpu-driver-bug-workarounds
  '';
  xdg.configFile."niri/config.kdl".source = ./config/config.kdl;
  xdg.configFile."niri/input.kdl".source = ./config/input.kdl;
  xdg.configFile."niri/keybindings.kdl".source = ./config/keybindings.kdl;
  xdg.configFile."niri/layout.kdl".source = ./config/layout.kdl;
  xdg.configFile."niri/outputs.kdl".source = ./config/outputs.kdl;
  xdg.configFile."niri/rules.kdl".source = ./config/rules.kdl;
  xdg.configFile."niri/workspaces.kdl".source = ./config/workspaces.kdl;
}
