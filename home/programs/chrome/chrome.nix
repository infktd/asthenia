{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    
    extensions = [
      # Add extension IDs here if needed
    ];
  };
}
