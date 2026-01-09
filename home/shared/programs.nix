{ pkgs, ... }:

{
  programs = {
    # Terminal file manager with vim keybindings
    bat.enable = true;

    # Directory navigation
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Fuzzy finder
    fzf = {
      enable = true;
      defaultCommand = "fd --type file --follow";
      defaultOptions = [ "--height 20%" ];
    };

    # System monitor
    htop = {
      enable = true;
      settings = {
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };

    # JSON processor
    jq.enable = true;
  };
}
