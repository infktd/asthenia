# Zsh + Starship prompt
{ config, pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
    };
    shellAliases = {
      ll = "eza -lah"; ls = "eza"; cat = "bat";
      gs = "git status"; ga = "git add"; gc = "git commit"; gp = "git push";
      gl = "git log --oneline --graph";
      nrs = "sudo nixos-rebuild switch --flake .";
      nrt = "sudo nixos-rebuild test --flake .";
      hms = "home-manager switch --flake .";
    };
    initContent = ''
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = lib.concatStrings [
        "$username" "$hostname" "$directory"
        "$git_branch" "$git_status" "$nix_shell" "$character"
      ];
      character = { success_symbol = "[](bold green)"; error_symbol = "[](bold red)"; };
      directory = { truncation_length = 3; truncate_to_repo = true; style = "bold cyan"; read_only = " 󰌾"; };
      git_branch = { symbol = " "; style = "bold purple"; };
      git_status = {
        style = "bold yellow";
        conflicted = "󰦖 "; ahead = "⇡\${count}"; behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = " 󰓧 "; stashed = " 󰋞 "; modified = " 󰏫 ";
        staged = " 󰄬 "; renamed = " 󰁕 "; deleted = " 󰆴 ";
      };
      nix_shell = { symbol = "  "; format = "via [$symbol$state]($style) "; style = "bold blue"; };
      username = { show_always = true; format = "[$user]($style) "; style_user = "bold yellow"; };
      hostname = { ssh_only = false; format = "on [$hostname]($style) "; style = "bold green"; disabled = true; };
    };
  };
}
