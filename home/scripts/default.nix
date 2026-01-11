# =============================================================================
# CUSTOM USER SCRIPTS
# =============================================================================
# Package definitions for custom shell scripts
# Scripts are made available as system commands
#
# PACKAGING APPROACH:
# - Each script gets its own .nix file
# - callPackage builds each script into a derivation
# - Scripts placed in $PATH automatically
#
# CURRENT SCRIPTS:
# - asthenia: NixOS and Home Manager rebuild helper
#
# SCRIPT ACCESS:
# - Available after home-manager switch
# - Run directly: asthenia --help
# - Located in: ~/.nix-profile/bin/
#
# ADDING NEW SCRIPTS:
# 1. Create <script-name>.nix in this directory
# 2. Use writeShellScriptBin or writeShellScript
# 3. Add entry here: <name> = callPackage ./<script-name>.nix { };
# 4. Script will be available after next home-manager switch
# =============================================================================
{ callPackage, ... }:

{
  # ---------------------------------------------------------------------------
  # REBUILD HELPER SCRIPT
  # ---------------------------------------------------------------------------
  # Unified script for rebuilding NixOS and Home Manager configurations
  #
  # FEATURES:
  # - Switch NixOS, Home Manager, or both
  # - Auto-detects current Home Manager profile
  # - Updates flake inputs before rebuilding
  # - Handles sudo automatically when needed
  #
  # USAGE:
  #   asthenia --help              # Show help
  #   asthenia --switch nixos      # Rebuild system
  #   asthenia --switch hm         # Rebuild user config
  #   asthenia --switch all        # Rebuild both
  #   asthenia --update            # Update inputs first
  #
  # IMPLEMENTATION: See ./asthenia.nix for full script
  # ---------------------------------------------------------------------------
  asthenia = callPackage ./asthenia.nix { };
  
  # ---------------------------------------------------------------------------
  # ADDITIONAL SCRIPT EXAMPLES
  # ---------------------------------------------------------------------------
  # Uncomment or add new scripts:
  #
  # Simple hello world example:
  # hello-nix = callPackage ./example-script.nix { };
  #
  # System maintenance script:
  # nix-cleanup = callPackage ./nix-cleanup.nix { };
  #
  # Backup script:
  # backup-home = callPackage ./backup-home.nix { };
  #
  # Development environment launcher:
  # dev-shell = callPackage ./dev-shell.nix { };
  # ---------------------------------------------------------------------------
}
