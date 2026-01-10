
{ config, pkgs, lib, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      "window-decoration" = "none";
      "clipboard-read" = "allow";
      "clipboard-write" = "allow";
      theme = "Oxocarbon";
      background = "#161616";
      foreground = "#f2f4f8";
      "selection-background" = "#393939";
      "selection-foreground" = "#626262";
      "cursor-color" = "#ffffff";
      "cursor-text" = "#000000";
      "cursor-style" = "block_hollow";
      "font-style" = "JetBrainsMono";
    };
  };
}
