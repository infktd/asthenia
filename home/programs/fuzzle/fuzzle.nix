{ lib, pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size 10";
        icon-theme = "BeautyLine";
        horizontal-pad = "10";
        layer = "top";
        icons-enabled = "no";
        lines = "5";
        terminal = lib.exe pkgs.alacritty;
      };
      colors = {
        # Catppuccin Mocha palette
        background = "1e1e2eff"; # base
        text =       "cdd6f4ff"; # text
        match =      "a6adc8ff"; # subtext1
        selection =  "585b70ff"; # surface1
        border =     "89b4faff"; # blue
        prompt =     "f5c2e7ff"; # pink
        selection-text = "f5e0dcff"; # rosewater
        selection-match = "f38ba8ff"; # red
        # You can further customize with other Catppuccin colors if desired
      };
      key-bindings = {
        execute-or-next = "tab";
      };
    };
  };
}