# =============================================================================
# HYPRPAPER CONFIGURATION
# =============================================================================
# Nix configuration for Hyprpaper wallpaper daemon.
#
# This provides wallpaper management for Hyprland with:
# - Multi-monitor support
# - Wallpaper preloading for performance
# - Runtime wallpaper switching via IPC
# - Fallback solid color background
# =============================================================================

{ config, lib, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    
    settings = {
      # IPC for runtime wallpaper changes
      ipc = true;
      
      # Disable splash screen
      splash = false;
      
      # Set wallpaper for each monitor using the new block syntax
      wallpaper = [
        {
          monitor = "DP-1";
          path = "/home/infktd/Wallpaper/pawel-czerwinski-379VdcbeFaQ-unsplash.jpg";
        }
        {
          monitor = "DP-2";
          path = "/home/infktd/Wallpaper/pawel-czerwinski-379VdcbeFaQ-unsplash.jpg";
        }
      ];
    };
  };
}