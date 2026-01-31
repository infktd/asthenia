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
  # Nix daemon and package manager settings
  nix = {
    # Enable flakes and new nix command
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Automatic garbage collection
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };  # Weekly on Sunday at 2am
      options = "--delete-older-than 30d";
    };

    # Optimize store automatically
    optimise = {
      automatic = true;
    };

    settings = {
      # Allow unfree packages
      allowed-users = [ "@admin" ];

      # Trusted users who can configure binary caches
      trusted-users = [ "root" "jayne" ];
    };
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
