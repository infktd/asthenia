# =============================================================================
# MAKO NOTIFICATION CONFIGURATION
# =============================================================================
# Nix configuration for Mako notification daemon.
#
# This provides Wayland-native notifications for Hyprland with:
# - Dark theme matching system colors
# - Grouped notifications by application
# - Auto-dismiss with configurable timeouts
# - Icon support and progress bars
# =============================================================================

{ config, lib, pkgs, ... }:

{
  services.mako = {
    enable = true;
    
    settings = {
      # Appearance
      background-color = "#2b303b";
      text-color = "#ffffff";
      border-color = "#65737e";
      border-size = 2;
      border-radius = 8;
      padding = "10";
      margin = "10";
      
      # Font
      font = "JetBrainsMono Nerd Font 12";
      
      # Layout
      width = 350;
      height = 100;
      anchor = "top-right";
      
      # Behavior
      default-timeout = 5000;
      ignore-timeout = true;
      group-by = "app-name";
      max-visible = 5;
      
      # Icons
      icons = true;
      max-icon-size = 48;
      
      # Actions
      actions = true;
      
      # Progress bar
      progress-color = "over #5588aa";
    };
    
    # Extra configuration for different urgency levels
    extraConfig = ''
      [urgency=low]
      border-color=#65737e
      default-timeout=2000
      
      [urgency=normal]
      border-color=#ab7967
      default-timeout=5000
      
      [urgency=critical]
      border-color=#bf616a
      default-timeout=0
    '';
  };
}