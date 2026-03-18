# All program configurations
{ pkgs, config, lib, isDarwin ? false, ... }: {

  imports = [ ./shell.nix ./zellij.nix ./crush.nix ]
    ++ lib.optionals (!isDarwin) [ ./fuzzel.nix ];

  programs = {
    # Alacritty terminal (Claude Dark theme)
    alacritty = {
      enable = true;
      settings = {
        window = { padding = { x = 8; y = 8; }; decorations = "Buttonless"; opacity = 1.0; startup_mode = "Windowed"; option_as_alt = "Both"; };
        font = {
          size = 10.0;
          normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
          bold   = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
          italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
        };
        scrolling = { history = 10000; multiplier = 3; };
        cursor.style = { shape = "Block"; blinking = "On"; };
        selection.save_to_clipboard = true;
        terminal.osc52 = "CopyPaste";
        colors = {
          primary   = { foreground = "#E8E0D4"; background = "#2A2520"; };
          cursor    = { cursor = "#D97757"; text = "#2A2520"; };
          selection = { background = "#4A423A"; text = "#E8E0D4"; };
          normal = { black = "#1A1815"; red = "#D97757"; green = "#7BAA8E"; yellow = "#D4A44D"; blue = "#6B8B9C"; magenta = "#B68F9A"; cyan = "#8AABA1"; white = "#F5F1E8"; };
          bright = { black = "#3D3529"; red = "#E8875F"; green = "#8BBAA0"; yellow = "#E4B45D"; blue = "#7B9BAC"; magenta = "#C69FAA"; cyan = "#9ABBB1"; white = "#FAF8F3"; };
        };
      };
    };

    bat.enable = true;
    chromium = lib.mkIf (!isDarwin) { enable = true; package = pkgs.chromium; };
    direnv = { enable = true; nix-direnv.enable = true; };
    discord = lib.mkIf (!isDarwin) { enable = true; };
    fzf = { enable = true; defaultCommand = "fd --type file --follow"; defaultOptions = [ "--height 20%" ]; };

    # Git + GitHub CLI
    git = {
      enable = true;
      signing = { key = "5C39B8FCD1521E8E"; signByDefault = true; };
      settings = {
        user = { name = "infktd"; email = "25016104+infktd@users.noreply.github.com"; };
        url."git@github.com:".insteadOf = "https://github.com/";
        init.defaultBranch = "main"; pull.rebase = true; push.autoSetupRemote = true;
        diff.colorMoved = "default"; merge.conflictstyle = "diff3";
        gpg.program = "${pkgs.gnupg}/bin/gpg";
      };
    };
    gh = { enable = true; gitCredentialHelper.enable = true; settings.git_protocol = "ssh"; };

    htop = { enable = true; settings = { sort_direction = true; sort_key = "PERCENT_CPU"; }; };
    jq.enable = true;
    vscode.enable = true;
    yazi = { enable = true; enableFishIntegration = true; shellWrapperName = "yy"; };
    zed-editor.enable = true;
  };

  xdg.configFile."gh/config.yml".force = true;
}
