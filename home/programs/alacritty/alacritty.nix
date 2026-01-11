{ config, pkgs, lib, ... }:

let
  oxocarbonToml = pkgs.writeText "theme.toml" ''
[colors.primary]
background = "#161616"
foreground = "#f2f4f8"

[colors.normal]
black   = "#262626"
red     = "#ee5396"
green   = "#42be65"
yellow  = "#ffe97b"
blue    = "#33b1ff"
magenta = "#be95ff"
cyan    = "#3ddbd9"
white   = "#dde1e6"

[colors.bright]
black   = "#393939"
red     = "#ff7eb6"
green   = "#57fa99"
yellow  = "#fddc6c"
blue    = "#78a9ff"
magenta = "#d4bbff"
cyan    = "#08bdba"
white   = "#ffffff"
'';
in
{
  xdg.configFile."alacritty/theme.toml".source = oxocarbonToml;
  
  
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [ "~/.config/alacritty/theme.toml" ];
      font = {
        normal.family = "monospace";
        size = 12.0;
      };
      window = {
        opacity = 0.95;
        padding = { x = 8; y = 8; };
      };
    };
  };
}
