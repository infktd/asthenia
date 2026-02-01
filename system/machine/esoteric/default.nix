# =============================================================================
# ESOTERIC - MACOS SYSTEM CONFIGURATION
# =============================================================================
# nix-darwin configuration for esoteric (Apple Silicon MacBook)
#
# ARCHITECTURE: aarch64-darwin (Apple Silicon M-series)
#
# WHAT NIX-DARWIN MANAGES:
# - Nix daemon and settings
# - Homebrew packages (via homebrew module)
# - macOS system defaults (Dock, Finder, etc.)
# - System environment and shells
# - Launch agents and daemons
#
# WHAT IT DOESN'T MANAGE:
# - User-level configs (handled by Home Manager)
# - GUI app preferences (most are per-user)
#
# USAGE:
# - Build: nix build .#darwinConfigurations.esoteric.system
# - Switch: darwin-rebuild switch --flake .#esoteric
# =============================================================================
{ config, lib, pkgs, inputs, ... }:

{
  # === IMPORTS ===
  imports = [
    ./homebrew.nix
  ];

  # === APPLICATION ALIASES ===
  # Create macOS aliases for Nix apps so Spotlight can index them
  # Symlinks don't work with Spotlight - must use native macOS aliases
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = [ "/Applications" ];
    };
  in
    lib.mkForce ''
      # Set up applications in /Applications/Nix Apps
      echo "setting up /Applications/Nix Apps..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' ';' |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done

      # Also handle Home Manager apps for user jayne
      HM_APPS="/Users/jayne/Applications/Home Manager Apps"
      if [ -e "$HM_APPS" ]; then
        echo "setting up Home Manager apps..." >&2
        rm -rf "/Applications/Home Manager Apps"
        mkdir -p "/Applications/Home Manager Apps"
        # Resolve the HM_APPS path (it's a symlink to the store)
        HM_APPS_REAL=$(${pkgs.coreutils}/bin/readlink -f "$HM_APPS")
        # Find all .app entries (they are symlinks in the store)
        find "$HM_APPS_REAL" -maxdepth 1 -name "*.app" -type l |
        while read -r lnk; do
          # Resolve the symlink to get the actual app bundle
          src=$(${pkgs.coreutils}/bin/readlink -f "$lnk")
          app_name=$(basename "$lnk")
          echo "aliasing $app_name -> $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Home Manager Apps/$app_name"
        done
      fi
    '';

  # === ENVIRONMENT ===
  # System-wide environment variables
  environment = {
    # System-wide packages available to all users
    systemPackages = with pkgs; [
      # --- Development Tools ---
      git
      vim

      # --- System Utilities ---
      coreutils  # GNU coreutils for consistency with Linux
    ];
  };

  # === FONTS ===
  # System-wide fonts (managed by Nix)
  fonts = {
    packages = with pkgs; [
      # Nerd Fonts for terminal and editor icons
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
    ];
  };

  # === NETWORKING ===
  networking = {
    computerName = "esoteric";
    hostName = "esoteric";
    localHostName = "esoteric";
  };

  # === NIX ===
  # Disable nix-darwin's Nix management - Determinate Nix handles the daemon
  # Determinate already manages: flakes, garbage collection, store optimization
  # Configure Determinate settings via: /etc/nix/nix.conf or determinate-nixd
  nix.enable = false;

  # Nix settings (still applied even with Determinate Nix managing the daemon)
  nix.settings = {
    # Trust the main user to use substituters and other restricted settings
    trusted-users = [ "root" "jayne" ];

    # Additional binary caches for faster builds
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://asthenia.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "asthenia.cachix.org-1:XgoFA0Dx9EB00nXiJn82LSUVn2iko0L5o62gkm4x6aw="
    ];
  };

  # === PROGRAMS ===
  # System-wide program configuration
  programs = {
    # Zsh as default shell
    zsh = {
      enable = true;
    };
  };

  # === SECURITY ===
  security = {
    pam = {
      services = {
        # Enable Touch ID for sudo authentication
        sudo_local = {
          touchIdAuth = true;
        };
      };
    };
  };

  # === SYSTEM ===
  system = {
    # Primary user for system operations (required by nix-darwin)
    # This user will be used for applying system defaults that require a user context
    primaryUser = "jayne";

    # macOS system defaults
    defaults = {
      # --- Dock ---
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.4;
        minimize-to-application = true;
        mru-spaces = false;  # Don't rearrange spaces based on recent use
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
      };

      # --- Finder ---
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;  # Show hidden files
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";  # List view
        QuitMenuItem = true;  # Allow quitting Finder
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      # --- Global Settings ---
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";  # Dark mode
        AppleKeyboardUIMode = 3;  # Full keyboard access
        ApplePressAndHoldEnabled = false;  # Key repeat instead of accent menu
        InitialKeyRepeat = 15;  # Faster key repeat
        KeyRepeat = 2;  # Faster key repeat rate
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      # --- Screenshots ---
      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
      };

      # --- Trackpad ---
      trackpad = {
        Clicking = true;  # Tap to click
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # Used for backwards compatibility
    stateVersion = 4;
  };

  # === USERS ===
  users = {
    users = {
      jayne = {
        description = "jayne";
        home = "/Users/jayne";
      };
    };
  };
}
