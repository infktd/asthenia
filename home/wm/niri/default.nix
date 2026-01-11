{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib.file) mkOutOfStoreSymlink;

  nerdFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
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
{
  imports = [
    ../../shared
  ];

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  home = {
    inherit packages;
    stateVersion = "24.11";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      SHELL = "${lib.exe pkgs.zsh}";
      MOZ_ENABLE_WAYLAND = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      # NVIDIA + Wayland performance
      __GL_GSYNC_ALLOWED = 0;
      __GL_VRR_ALLOWED = 0;
      WLR_NO_HARDWARE_CURSORS = 1;
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Aggressive performance tuning
      __GL_YIELD = "NOTHING";
      __GL_THREADED_OPTIMIZATION = 1;
      CLUTTER_PAINT = "disable-clipped-redraws:disable-culling";
      CLUTTER_VBLANK = "none";
    };
  };

  fonts.fontconfig.enable = true;

  # Use modular config files
  xdg.configFile."niri/config.kdl".source = ./config/config.kdl;
  xdg.configFile."niri/input.kdl".source = ./config/input.kdl;
  xdg.configFile."niri/keybindings.kdl".source = ./config/keybindings.kdl;
  xdg.configFile."niri/outputs.kdl".source = ./config/outputs.kdl;
  xdg.configFile."niri/layout.kdl".source = ./config/layout.kdl;

  # e.g. for slack, etc
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
    --disable-gpu-driver-bug-workarounds
  '';

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "gtk" "gnome" ];
      };
      niri = {
        default = [ "gtk" "gnome" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    xdgOpenUsePortal = true;
  };
}
