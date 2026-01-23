
{ lib, pkgs, ... }:

{
  programs.gh = {
    enable = true;
    # Optional: configure git credential helper
    gitCredentialHelper.enable = true;
    # Optional: add aliases or extensions
    settings = {
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
    # Optional: install extensions from nixpkgs
    # extensions = [ pkgs.gh-s ];
  };
}