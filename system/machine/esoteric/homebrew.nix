# =============================================================================
# HOMEBREW CONFIGURATION
# =============================================================================
# nix-darwin can manage Homebrew packages declaratively
# This provides GUI apps (casks) that aren't available or optimal in Nix
#
# PREREQUISITES:
# Homebrew must be installed manually first:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#
# HOW IT WORKS:
# - nix-darwin calls `brew bundle` with a generated Brewfile
# - Packages listed here are installed/updated on darwin-rebuild
# - Packages can optionally be removed if not listed (onActivation.cleanup)
#
# WHEN TO USE HOMEBREW VS NIX:
# - Use Nix: CLI tools, development packages, reproducibility matters
# - Use Homebrew casks: macOS GUI apps that need system integration
# - Use Mac App Store (mas): Apps only available on MAS
#
# USAGE:
# - Add packages to brews/casks/masApps below
# - Run: darwin-rebuild switch --flake .#esoteric
# =============================================================================
{ config, lib, pkgs, ... }:

{
  homebrew = {
    # Enable Homebrew management through nix-darwin
    enable = true;

    # ---------------------------------------------------------------------------
    # ACTIVATION BEHAVIOR
    # ---------------------------------------------------------------------------
    onActivation = {
      # Auto-update Homebrew during darwin-rebuild
      autoUpdate = true;

      # Cleanup behavior for packages not in this config:
      # - "none": Keep unlisted packages
      # - "uninstall": Remove unlisted packages (managed by Homebrew)
      # - "zap": Remove unlisted packages and their configs
      # Start with "none" to avoid removing existing packages
      # Change to "uninstall" once you've added all your packages
      cleanup = "uninstall";

      # Upgrade packages during darwin-rebuild
      upgrade = true;
    };

    # ---------------------------------------------------------------------------
    # TAPS
    # ---------------------------------------------------------------------------
    # Additional Homebrew repositories
    # Note: homebrew/bundle and homebrew/services are now built into core Homebrew
    taps = [
    ];

    # ---------------------------------------------------------------------------
    # BREWS
    # ---------------------------------------------------------------------------
    # CLI tools installed via Homebrew (prefer Nix when possible)
    brews = [
      # Add CLI tools that don't work well with Nix on macOS
      # Example: "mas"  # Mac App Store CLI
    ];

    # ---------------------------------------------------------------------------
    # CASKS
    # ---------------------------------------------------------------------------
    # GUI applications that MUST be installed via Homebrew
    # Only include apps not available in nixpkgs or requiring macOS integration
    #
    # Currently empty - all apps managed by Nix/home-manager
    # Add casks here only if absolutely necessary (e.g., apps requiring
    # deep macOS integration not available in nixpkgs)
    casks = [
    ];

    # ---------------------------------------------------------------------------
    # MAC APP STORE
    # ---------------------------------------------------------------------------
    # Apps from the Mac App Store (requires `mas` CLI and signed-in Apple ID)
    # Format: "App Name" = <app-id>;
    # Find app IDs with: mas search <app-name>
    masApps = {
      # Example:
      # "Xcode" = 497799835;
    };
  };
}
