{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" ];
    };
    # Add Starship initialization to .zshrc
    initExtra = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {};
  };
}
