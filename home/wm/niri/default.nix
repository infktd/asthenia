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
  ] ++ fontPkgs ++ audioPkgs;
in
{
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  imports = [
    ../../shared
    ../../programs/chrome/chrome.nix
    ../../programs/fuzzle/fuzzle.nix
    ../../programs/kitty/kitty.nix
    ../../programs/nvf/nvf.nix
    ../../programs/vscode/vscode.nix
    ../../programs/discord/discord.nix
    ../../programs/obsidian/obsidian.nix
    ../../programs/yazi/yazi.nix

  ];

  home = {
    inherit packages;
    stateVersion = "24.11";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      SHELL = "${lib.exe pkgs.fish}";
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

  # Niri configuration
  xdg.configFile."niri/config.kdl".source = ./config/config.kdl;

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
