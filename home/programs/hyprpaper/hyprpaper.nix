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
      # Preload wallpapers (add your wallpaper paths here)
      # preload = [
      #   "~/Pictures/wallpaper.jpg"
      # ];
      
      # Set wallpaper for monitors
      # Format: wallpaper = "monitor,/path/to/wallpaper"
      wallpaper = [
        ",rgba(1e1e2eff)"  # Solid color fallback
      ];
      
      # Disable splash screen
      splash = false;
      
      # Enable IPC for runtime wallpaper changes
      ipc = "on";
    };
  };
}