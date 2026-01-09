{ lib, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "infktd";
        email = "25016104+infktd@users.noreply.github.com";
      };
    };
  };
}
