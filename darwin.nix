# All Darwin config: nix, users, system defaults, homebrew, spotlight
{ config, lib, pkgs, inputs, ... }: {

  environment.systemPackages = with pkgs; [ git vim coreutils ];
  fonts.packages = with pkgs; [ nerd-fonts.fira-code nerd-fonts.iosevka nerd-fonts.jetbrains-mono ];

  nix.enable = false; # Determinate Nix manages the daemon
  nix.settings = {
    trusted-users = [ "root" "jayne" ];
    substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" "https://devenv.cachix.org" "https://asthenia.cachix.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "asthenia.cachix.org-1:XgoFA0Dx9EB00nXiJn82LSUVn2iko0L5o62gkm4x6aw="
    ];
  };

  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "jayne";
    keyboard = { enableKeyMapping = true; remapCapsLockToEscape = true; };
    stateVersion = 4;
    defaults = {
      dock = {
        autohide = true; autohide-delay = 0.0; autohide-time-modifier = 0.4;
        minimize-to-application = true; mru-spaces = false;
        orientation = "bottom"; show-recents = false; tilesize = 48;
      };
      finder = {
        AppleShowAllExtensions = true; AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false; FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true; ShowPathbar = true; ShowStatusBar = true;
      };
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark"; AppleKeyboardUIMode = 3; ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15; KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false; NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false; NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false; NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true; NSNavPanelExpandedStateForSaveMode2 = true;
      };
      screencapture = { location = "~/Pictures/Screenshots"; type = "png"; };
      trackpad = { Clicking = true; TrackpadRightClick = true; TrackpadThreeFingerDrag = true; };
    };
  };

  users.users.jayne = { description = "jayne"; home = "/Users/jayne"; };

  homebrew = {
    enable = true;
    onActivation = { autoUpdate = true; cleanup = "uninstall"; upgrade = true; };
    taps = []; brews = [ "libomp" ]; casks = [ "temurin@11" ]; masApps = {};
  };

  # Spotlight-compatible aliases for Nix apps
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv { name = "system-applications"; paths = config.environment.systemPackages; pathsToLink = [ "/Applications" ]; };
  in lib.mkForce ''
    echo "setting up /Applications/Nix Apps..." >&2
    rm -rf /Applications/Nix\ Apps
    mkdir -p /Applications/Nix\ Apps
    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' ';' |
    while read -r src; do
      app_name=$(basename "$src")
      echo "copying $src" >&2
      ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
    done
    HM_APPS="/Users/jayne/Applications/Home Manager Apps"
    if [ -e "$HM_APPS" ]; then
      echo "setting up Home Manager apps..." >&2
      rm -rf "/Applications/Home Manager Apps"
      mkdir -p "/Applications/Home Manager Apps"
      HM_APPS_REAL=$(${pkgs.coreutils}/bin/readlink -f "$HM_APPS")
      find "$HM_APPS_REAL" -maxdepth 1 -name "*.app" -type l |
      while read -r lnk; do
        src=$(${pkgs.coreutils}/bin/readlink -f "$lnk")
        app_name=$(basename "$lnk")
        echo "aliasing $app_name -> $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Home Manager Apps/$app_name"
      done
    fi
  '';
}
