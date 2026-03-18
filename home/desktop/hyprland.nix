# Hyprland user config: WM settings, keybindings
{ config, lib, pkgs, inputs, ... }: {

  imports = [
    ./wayland.nix
    ../programs/waybar.nix
    ../programs/mako.nix
    ../programs/hyprlock.nix
    ../programs/hypridle.nix
    ../programs/hyprpaper.nix
  ];

  home.packages = with pkgs; [ rofi slurp ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = false; # Prevent restart on rebuild

    settings = {
      monitor = [
        "DP-1,2560x1440@144,0x1440,1"
        "DP-2,2560x1440@144,0x0,1"
      ];

      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];

      exec-once = [ "waybar" "mako" "hyprpaper" "hypridle" ];

      general = {
        gaps_in = 5; gaps_out = 12; border_size = 1;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false; allow_tearing = false; layout = "dwindle";
      };

      decoration = {
        rounding = 10; active_opacity = 1.0; inactive_opacity = 0.95;
        shadow = { enabled = true; range = 4; render_power = 3; color = "rgba(1a1a1aee)"; };
        blur = { enabled = true; size = 3; passes = 1; };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"   "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"     "borderangle, 1, 8, default"
          "fade, 1, 7, default"        "workspaces, 1, 6, default"
        ];
      };

      dwindle = { pseudotile = true; preserve_split = true; };
      master = { new_on_top = true; };
      misc = { force_default_wallpaper = -1; disable_hyprland_logo = true; };
      input = { kb_layout = "us"; follow_mouse = 1; sensitivity = 0; };

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, RETURN, exec, alacritty"  "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"  "$mainMod, E, exec, nemo"
        "$mainMod, V, togglefloating,"  "$mainMod, D, exec, fuzzel"
        "$mainMod, P, pseudo,"  "$mainMod, J, togglesplit,"
        "$mainMod, left, movefocus, l"  "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"    "$mainMod, down, movefocus, d"
        "$mainMod, 1, workspace, 1"  "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"  "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"  "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"  "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"  "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"  "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"  "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"  "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"  "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"  "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"  "$mainMod, mouse_up, workspace, e-1"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ''$mainMod, X, exec, grim -g "$(slurp)" - | wl-copy''
        ''$mainMod SHIFT, X, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png''
        "$mainMod, L, exec, hyprlock"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindm = [ "$mainMod, mouse:272, movewindow" "$mainMod, mouse:273, resizewindow" ];
    };
  };
}
