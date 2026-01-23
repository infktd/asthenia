
{ lib, pkgs, ... }:

{
  xdg.configFile."gh/config.yml".force = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}