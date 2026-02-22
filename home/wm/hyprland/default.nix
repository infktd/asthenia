# =============================================================================
# HYPRLAND HOME MANAGER CONFIGURATION
# =============================================================================
# User-level configuration for Hyprland window manager.
#
# This module provides:
# - NVIDIA-optimized environment variables for Wayland
# - Font and cursor configuration
# - Audio control utilities
# - XDG configuration file links for Hyprland
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
    ../../programs/waybar/waybar.nix
    ../../programs/mako/mako.nix
    ../../programs/hyprlock/hyprlock.nix
    ../../programs/hypridle/hypridle.nix
    ../../programs/hyprpaper/hyprpaper.nix
  ];

  # === WAYLAND WINDOW MANAGER ===
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    # CRITICAL: Disable systemd integration to prevent Hyprland from restarting
    # during NixOS rebuilds. This is the key difference from Niri which doesn't
    # have this issue - Niri uses niri-session which handles systemd properly.
    # With systemd.enable = true, Hyprland's systemd user services restart on
    # every system update, causing video loss and monitor reconfiguration.
    systemd.enable = false;

    settings = {
      # === MONITORS ===
      # Fixed monitor configuration - won't change during rebuilds since
      # systemd integration is disabled above
      monitor = [
        "DP-1,2560x1440@144,0x1440,1"
        "DP-2,2560x1440@144,0x0,1"
      ];

      # === NVIDIA OPTIMIZATIONS ===
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];

      # === STARTUP ===
      exec-once = [
        "waybar"
        "mako"
        "hyprpaper"
        "hypridle"
      ];

      # === GENERAL ===
      general = {
        gaps_in = 5;
        gaps_out = 12;
        border_size = 1;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      # === DECORATION ===
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = .95;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      # === ANIMATIONS ===
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # === LAYOUT ===
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_on_top = true;
      };

      # === MISC ===
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
      };

      # === INPUT ===
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
      };

      # === KEYBINDINGS ===
      "$mainMod" = "SUPER";

      bind = [
        # Basic window management
        "$mainMod, RETURN, exec, alacritty"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, nemo"
        "$mainMod, V, togglefloating,"
        "$mainMod, D, exec, fuzzel"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"

        # Move focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move windows to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Media keys
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # Screenshot
        "$mainMod, X, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mainMod SHIFT, X, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"

        # Lock screen
        "$mainMod, L, exec, hyprlock"
      ];

      binde = [
        # Volume
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # Brightness
        ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindm = [
        # Move/resize windows with mouse
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
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
