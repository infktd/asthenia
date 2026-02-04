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
    
    # Appearance
    backgroundColor = "#2b303b";
    textColor = "#ffffff";
    borderColor = "#65737e";
    borderSize = 2;
    borderRadius = 8;
    padding = "10";
    margin = "10";
    
    # Font
    font = "JetBrainsMono Nerd Font 12";
    
    # Layout
    width = 350;
    height = 100;
    anchor = "top-right";
    
    # Behavior
    defaultTimeout = 5000;
    ignoreTimeout = true;
    groupBy = "app-name";
    maxVisible = 5;
    
    # Icons
    icons = true;
    maxIconSize = 48;
    iconPath = "/usr/share/icons/Adwaita";
    
    # Actions
    actions = true;
    
    # History
    history = true;
    maxHistory = 20;
    
    # Progress bar
    progressColor = "over #5588aa";
    
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