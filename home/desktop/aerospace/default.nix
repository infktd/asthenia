# Aerospace tiling WM (macOS)
{ config, lib, pkgs, inputs, ... }:

let
  nerdFonts = with (pkgs.nerd-fonts); [ fira-code iosevka jetbrains-mono ];
  fontPkgs = with pkgs; [ font-awesome material-design-icons ] ++ nerdFonts;
in
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [ aerospace stripe-cli ] ++ fontPkgs;
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${lib.exe pkgs.zsh}";
  };

  xdg.configFile."aerospace/aerospace.toml".source = ./config/aerospace.toml;
}
