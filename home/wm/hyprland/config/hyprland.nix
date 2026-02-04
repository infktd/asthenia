# =============================================================================
# HYPRLAND CONFIGURATION
# =============================================================================
# Main configuration file for Hyprland window manager in pure Nix format.
# 
# This provides a functional setup optimized for NVIDIA GPUs with:
# - Basic keybindings for window management
# - NVIDIA-optimized rendering settings
# - Workspace configuration
# - Auto-start applications (waybar, mako, hyprpaper)
# =============================================================================

''
# === MONITORS ===
# Configure your monitors here
# Format: monitor=name,resolution@refresh,position,scale
monitor=,preferred,auto,1

# === NVIDIA OPTIMIZATIONS ===
# Specific settings for NVIDIA GPUs on Wayland
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# === STARTUP ===
# Programs to start automatically
exec-once = waybar
exec-once = mako
exec-once = hyprpaper
exec-once = hypridle

# === GENERAL ===
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    resize_on_border = false
    allow_tearing = false
    layout = dwindle
}

# === DECORATION ===
decoration {
    rounding = 10
    active_opacity = 1.0
    inactive_opacity = 1.0
    
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
    
    blur {
        enabled = true
        size = 3
        passes = 1
        vibrancy = 0.1696
    }
}

# === ANIMATIONS ===
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# === LAYOUT ===
dwindle {
    pseudotile = true
    preserve_split = true
}

master {
    new_status = master
}

# === GESTURES ===
gestures {
    workspace_swipe = false
}

# === MISC ===
misc {
    force_default_wallpaper = -1
    disable_hyprland_logo = false
}

# === INPUT ===
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =
    
    follow_mouse = 1
    sensitivity = 0
    
    touchpad {
        natural_scroll = false
    }
}

# === KEYBINDINGS ===
# Modifier key (Super/Windows key)
$mainMod = SUPER

# Basic window management
bind = $mainMod, Q, exec, alacritty
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, nemo
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Example special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Media keys
binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
binde = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioPause, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Screen brightness
binde = , XF86MonBrightnessUp, exec, brightnessctl s 10%+
binde = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

# Screenshot
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy

# Lock screen
bind = $mainMod, L, exec, hyprlock
''