# =============================================================================
# HOME MANAGER CONFIGURATION BUILDER
# =============================================================================
# This module creates Home Manager configurations (user-level profiles)
# Called by pkgs.builders.mkHome in lib/overlays.nix
#
# STANDALONE HOME MANAGER:
# This configuration uses standalone Home Manager (not the NixOS module)
# Benefits:
# - Full access to all Home Manager options
# - Updates don't require sudo
# - Independent user/system update cycles
# - Per-user customization support
#
# PROFILE ARCHITECTURE:
# - Base modules: Applied to ALL profiles (registry, extra config)
# - Profile-specific mods: Additional modules per profile
# - Multiple profiles allow different desktop environments
#
# USAGE:
# - Build: nix build .#homeConfigurations.<profile>.activationPackage
# - Switch: home-manager switch --flake .#<profile>
# - Rollback: home-manager generations
# =============================================================================
{ extraHomeConfig, inputs, system, pkgs, ... }:

let
  # ---------------------------------------------------------------------------
  # BASE MODULES
  # ---------------------------------------------------------------------------
  # These modules are included in EVERY Home Manager profile
  #
  # 1. Nix registry: Makes 'nix run nixpkgs#...' use the same nixpkgs as the flake
  # 2. Extra config: Allows callers to inject additional modules
  #
  # PURPOSE OF NIX REGISTRY:
  # - Without this: 'nix run nixpkgs#hello' uses latest nixpkgs
  # - With this: 'nix run nixpkgs#hello' uses the pinned version from flake
  # - Ensures consistency between declarative and imperative nix commands
  # ---------------------------------------------------------------------------
  modules' = [
    # Pin nixpkgs registry to our flake input version
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
    
    # Allow additional modules to be injected from caller
    extraHomeConfig
  ];

  # ---------------------------------------------------------------------------
  # PROFILE BUILDER HELPER
  # ---------------------------------------------------------------------------
  # Creates a single Home Manager configuration with specified parameters
  #
  # PARAMETERS:
  # - hidpi: Enable HiDPI scaling (currently unused, reserved for future)
  # - mutable: Allow mutable file modifications (default: false for purity)
  # - mods: Additional modules to merge into this specific profile
  #
  # RETURNS:
  # A Home Manager configuration that can be built and activated
  #
  # HOW IT WORKS:
  # 1. Uses home-manager.lib.homeManagerConfiguration function
  # 2. Combines base modules' with profile-specific mods
  # 3. Passes special args (inputs) for use in imported modules
  # ---------------------------------------------------------------------------
  mkHome = { hidpi ? false, mutable ? false, mods ? [ ] }:
    inputs.home-manager.lib.homeManagerConfiguration {
      # Package set with our overlays applied
      inherit pkgs;
      
      # Combine base modules with profile-specific modules
      modules = modules' ++ mods;
      
      # Make inputs available in all modules as 'inputs' argument
      # Allows modules to access: inputs.nvf, inputs.niri-flake, etc.
      extraSpecialArgs = { inherit inputs; };
    };
in
# =============================================================================
# HOME MANAGER PROFILES
# =============================================================================
# Each profile represents a complete user environment configuration
# Profiles can be switched between without affecting system config
# =============================================================================
{
  # ---------------------------------------------------------------------------
  # DEFAULT PROFILE
  # ---------------------------------------------------------------------------
  # Minimal user configuration without window manager
  #
  # INCLUDES:
  # - Core programs (git, zsh, alacritty, nvim, vscode, etc.)
  # - Shell configuration and scripts
  # - GTK themes
  # - Development tools
  #
  # USE CASES:
  # - Server environments without GUI
  # - Testing user config without desktop environment
  # - WSL or remote SSH development
  # - Base for creating new custom profiles
  #
  # SWITCH TO:
  #   home-manager switch --flake .#default
  # ---------------------------------------------------------------------------
  default = mkHome {
    mods = [ ../home/shared ];
  };

  # ---------------------------------------------------------------------------
  # NIRI PROFILE
  # ---------------------------------------------------------------------------
  # Full desktop environment with Niri window manager
  #
  # INCLUDES:
  # - Everything from 'default' profile (via import in niri config)
  # - Niri window manager configuration
  # - DMS (Dank Material Shell) for widgets
  # - Wayland-specific settings
  # - NVIDIA optimizations
  # - Desktop utilities (file manager, screenshot, clipboard)
  # - Audio controls and media players
  #
  # SYSTEM REQUIREMENTS:
  # - system/wm/niri.nix must be imported in NixOS config
  # - Wayland-compatible GPU drivers
  # - For NVIDIA: system/machine/<host>/nvidia.nix
  #
  # USE CASES:
  # - Primary desktop environment
  # - Scrollable tiling workflow
  # - Modern Wayland compositor with NVIDIA support
  #
  # SWITCH TO:
  #   home-manager switch --flake .#niri
  #
  # AFTER SWITCHING:
  #   Reboot or restart display manager to load Niri session
  # ---------------------------------------------------------------------------
  niri = mkHome {
    mods = [ ../home/wm/niri ];
  };
  
  # ---------------------------------------------------------------------------
  # ADDING NEW PROFILES
  # ---------------------------------------------------------------------------
  # To create a new profile:
  #
  # 1. Create profile directory: home/<profile-name>/
  # 2. Create default.nix that imports base config
  # 3. Add profile-specific modules and packages
  # 4. Add entry here:
  #
  #   myprofile = mkHome {
  #     mods = [ ../home/<profile-name> ];
  #   };
  #
  # PROFILE EXAMPLES:
  # - hyprland: Alternative Wayland compositor
  # - kde: Full KDE Plasma desktop
  # - minimal: Absolute minimal setup
  # - work: Work-specific tools and restrictions
  # ---------------------------------------------------------------------------
}
