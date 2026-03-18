# Fuzzel - Wayland app launcher (Catppuccin Mocha)
{ lib, pkgs, ... }: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size 10";
        icon-theme = "BeautyLine"; horizontal-pad = "10";
        layer = "top"; icons-enabled = "no"; lines = "5";
        terminal = lib.exe pkgs.alacritty;
      };
      colors = {
        background = "1e1e2eff"; text = "cdd6f4ff"; match = "a6adc8ff";
        selection = "585b70ff"; border = "89b4faff"; prompt = "f5c2e7ff";
        selection-text = "f5e0dcff"; selection-match = "f38ba8ff";
      };
      key-bindings.execute-or-next = "tab";
    };
  };
}
