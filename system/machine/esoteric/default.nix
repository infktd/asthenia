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
