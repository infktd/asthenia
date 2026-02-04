# =============================================================================
# HYPRLOCK CONFIGURATION
# =============================================================================
# Nix configuration for Hyprlock screen locker.
#
# This provides secure screen locking for Hyprland with:
# - Screenshot-based background with blur
# - Password input field
# - Clock and user greeting
# - Customizable appearance
# =============================================================================

{ config, lib, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 0;
        no_fade_in = false;
      };
      
      background = [{
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }];
      
      input-field = [{
        monitor = "";
        size = "200, 50";
        position = "0, -80";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(202, 211, 245)";
        inner_color = "rgb(91, 96, 120)";
        outer_color = "rgb(24, 25, 38)";
        outline_thickness = 5;
        placeholder_text = "<b>Password...</b>";
        shadow_passes = 2;
      }];
      
      label = [
        {
          monitor = "";
          text = "Hi there, $USER";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 25;
          font_family = "Noto Sans";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "$TIME";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 55;
          font_family = "Noto Sans";
          position = "0, 150";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}