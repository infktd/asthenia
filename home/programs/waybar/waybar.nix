# =============================================================================
# WAYBAR CONFIGURATION
# =============================================================================
# Nix configuration for Waybar status bar.
#
# Inspired by gvolpe's nix-config with:
# - Custom arrow separators for sleek design
# - Multi-segment clock display
# - MPRIS media player integration
# - Grouped power menu with drawer
# - Enhanced workspace icons
# - System monitoring (CPU, memory, disk, network)
# =============================================================================

{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        
        modules-left = [ 
          "custom/right-arrow-dark"
          "hyprland/workspaces"
          "custom/right-arrow-light"
          "custom/right-arrow-dark"
          "hyprland/window"
          "custom/left-arrow-dark"
          "custom/left-arrow-light"
        ];
        
        modules-center = [
          "custom/left-arrow-dark"
          "clock#1"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "clock#2"
          "custom/right-arrow-dark"
          "custom/right-arrow-light"
          "custom/right-arrow-dark"
          "clock#3"
          "custom/right-arrow-light"
        ];
        
        modules-right = [ 
          "custom/left-arrow-dark"
          "pulseaudio"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "network"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "memory"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "cpu"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "disk"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "tray"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "group/group-power"
        ];
        
        # Custom arrow separators
        "custom/left-arrow-dark" = {
          format = "";
          tooltip = false;
        };
        
        "custom/left-arrow-light" = {
          format = "";
          tooltip = false;
        };
        
        "custom/right-arrow-dark" = {
          format = "";
          tooltip = false;
        };
        
        "custom/right-arrow-light" = {
          format = "";
          tooltip = false;
        };
        
        # Hyprland workspaces
        "hyprland/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
          format = "{id}";
        };
        
        # Window title with rewrites
        "hyprland/window" = {
          format = "{}";
          rewrite = {
            "(.*) — Mozilla Firefox" = " $1";
            "~/(.*)" = "   [~/$1]";
            "vim (.*)" = "   [$1]";
          };
          max-length = 70;
          separate-outputs = true;
        };
        
        # Multi-segment clock
        "clock#1" = {
          format = "{:%a}";
          tooltip = false;
        };
        
        "clock#2" = {
          format = "{:%H:%M}";
          tooltip-format = "{:%A}";
        };
        
        "clock#3" = {
          format = "{:%b %d}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        
        # Audio
        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon}  {volume}%";
          format-muted = "MUTE";
          format-icons = {
            headphones = "";
            default = [ "" "" ];
          };
          scroll-step = 5;
          on-click = "pulsemixer";
          on-click-right = "pavucontrol";
        };
        
        # Network
        network = {
          format = "{ifname}";
          format-wifi = "{ipaddr}/{cidr} ";
          format-ethernet = "{ifname} ";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ipaddr}/{cidr} 󰊗";
          tooltip-format-disconnected = "Disconnected 󰌙";
          max-length = 50;
        };
        
        # CPU usage
        cpu = {
          interval = 5;
          format = "CPU {usage}%";
          tooltip = false;
        };
        
        # Memory usage
        memory = {
          interval = 5;
          format = "Mem {}%";
        };
        
        # Disk usage
        disk = {
          interval = 5;
          format = "Disk {percentage_used}%";
          path = "/";
        };
        
        # System tray
        tray = {
          icon-size = 20;
          show-passive-items = true;
        };
        
        # Power menu group with drawer
        "group/group-power" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 500;
            children-class = "not-power";
            transition-left-to-right = true;
          };
          modules = [
            "custom/power"
            "custom/quit"
            "custom/lock"
            "custom/reboot"
          ];
        };
        
        "custom/quit" = {
          format = "󰗼 ";
          tooltip = false;
          on-click = "hyprctl dispatch exit";
        };
        
        "custom/lock" = {
          format = "󰍁 ";
          tooltip = false;
          on-click = "hyprlock";
        };
        
        "custom/reboot" = {
          format = "󰜉 ";
          tooltip = false;
          on-click = "reboot";
        };
        
        "custom/power" = {
          format = "   ";
          tooltip = false;
          on-click = "poweroff";
        };
      };
    };
    
    style = ''
      * {
        font-size: 14px;
        font-family: "JetBrainsMono NFM", sans-serif;
      }

      window#waybar {
        background: #292b2e;
        color: #fdf6e3;
      }

      #custom-right-arrow-dark,
      #custom-left-arrow-dark {
        color: #1a1a1a;
      }
      
      #custom-right-arrow-light,
      #custom-left-arrow-light {
        color: #292b2e;
        background: #1a1a1a;
      }

      #workspaces,
      #clock.1,
      #clock.2,
      #clock.3,
      #pulseaudio,
      #memory,
      #cpu,
      #disk,
      #tray {
        background: #1a1a1a;
      }

      #workspaces button {
        padding: 0 2px;
        color: #fdf6e3;
      }

      #workspaces button.active {
        color: #268bd2;
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
      }

      #workspaces button.urgent {
        color: #ff6c6b;
      }

      #pulseaudio {
        color: #268bd2;
      }

      #memory {
        color: #2aa198;
      }

      #cpu {
        color: #6c71c4;
      }

      #disk {
        color: #b58900;
      }

      #clock,
      #pulseaudio,
      #memory,
      #cpu,
      #disk,
      #network {
        padding: 0 10px;
      }
      
      #window {
        margin-right: 35px;
        margin-left: 35px;
        color: #fdf6e3;
      }
      
      #network {
        color: #859900;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #tray {
        background-color: #2980b9;
      }
      
      #custom-quit,
      #custom-lock,
      #custom-reboot,
      #custom-power {
        background: #1a1a1a;
        color: #fdf6e3;
        padding: 0 5px;
      }
      
      #custom-quit:hover,
      #custom-lock:hover,
      #custom-reboot:hover,
      #custom-power:hover {
        color: #dc322f;
      }
    '';
  };
}