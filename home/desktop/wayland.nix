# Shared Wayland desktop config: NVIDIA env, fonts, audio, cursor
{ config, lib, pkgs, ... }:

let
  nerdFonts = with (pkgs.nerd-fonts); [ fira-code iosevka jetbrains-mono ];
in
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Desktop
    brightnessctl grim libnotify nemo networkmanagerapplet
    wl-clipboard xwayland-satellite-unstable
    # Fonts
    font-awesome material-design-icons
    # Audio
    paprefs pavucontrol playerctl pulsemixer
  ] ++ nerdFonts;

  home.pointerCursor = {
    gtk.enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
  };

  # NVIDIA + Wayland environment
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

  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
    --disable-gpu-driver-bug-workarounds
  '';
}
