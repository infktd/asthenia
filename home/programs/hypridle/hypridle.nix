# =============================================================================
# HYPRIDLE CONFIGURATION
# =============================================================================
# Nix configuration for Hypridle idle daemon.
#
# This provides automatic power management for Hyprland:
# - Screen lock after inactivity
# - Display power management
# - Suspend integration (optional)
# - Wake-on-activity detection
# =============================================================================

{ config, lib, pkgs, ... }:

{
  services.hypridle = {
    enable = true;
    
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      
      listener = [
        {
          timeout = 300; # 5 minutes
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600; # 10 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # Uncomment to enable suspend after 30 minutes
        # {
        #   timeout = 1800; # 30 minutes
        #   on-timeout = "systemctl suspend";
        # }
      ];
    };
  };
}