{ pkgs, config, lib, vars, ... }:

{
  imports = [
    ../programs/git/git.nix
    ../programs/kitty/kitty.nix
    ../programs/vscode/vscode.nix
    ../programs/nvf/nvf.nix
    ../programs/chrome/chrome.nix
    ../programs/discord/discord.nix
    ../programs/obsidian/obsidian.nix
    ../programs/yazi/yazi.nix
    ../programs/fuzzle/fuzzle.nix
  ];

  programs = {
    # Terminal file manager with vim keybindings
    bat.enable = true;

    # Directory navigation
    direnv = {
      enable = vars.development.enable;
      nix-direnv.enable = vars.development.enable;
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
