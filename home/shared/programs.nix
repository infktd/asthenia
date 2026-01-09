{ pkgs, config, lib, vars, ... }:

{
  imports = [
    ../programs/git/git.nix
  ] ++ lib.optional vars.applications.terminal.kitty ../programs/kitty/kitty.nix
    ++ lib.optional vars.applications.terminal.alacritty ../programs/alacritty/alacritty.nix
    ++ lib.optional vars.applications.terminal.wezterm ../programs/wezterm/wezterm.nix
    ++ lib.optional vars.applications.fileManager.yazi ../programs/yazi/yazi.nix
    ++ lib.optional vars.development.editors.vscode ../programs/vscode/vscode.nix
    ++ lib.optional vars.development.editors.neovim ../programs/nvf/nvf.nix
    ++ lib.optional vars.applications.browsers.chromium ../programs/chrome/chrome.nix
    ++ lib.optional vars.applications.communication.discord ../programs/discord/discord.nix
    ++ lib.optional vars.applications.other.obsidian ../programs/obsidian/obsidian.nix;

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
