# =============================================================================
# HOME MANAGER CONFIGURATION BUILDER
# =============================================================================
# This module creates Home Manager configurations (user-level profiles)
# Called by pkgs.builders.mkHome / mkHomeDarwin in lib/overlays.nix
#
# STANDALONE HOME MANAGER:
# This configuration uses standalone Home Manager (not the NixOS module)
# Benefits:
# - Full access to all Home Manager options
# - Updates don't require sudo
# - Independent user/system update cycles
# - Per-user customization support
#
# CROSS-PLATFORM SUPPORT:
# - isDarwin parameter controls which profiles are generated
# - Linux profiles: default, niri
# - macOS profiles: default-darwin, aerospace
# - Shared modules receive isDarwin for conditional logic
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
{ extraHomeConfig, inputs, system, pkgs, isDarwin ? false, ... }:

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

    # sops-nix home-manager module for secrets management
    inputs.sops-nix.homeManagerModules.sops

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
  # 3. Passes special args (inputs, isDarwin) for use in imported modules
  # ---------------------------------------------------------------------------
  mkProfile = { hidpi ? false, mutable ? false, mods ? [ ] }:
    inputs.home-manager.lib.homeManagerConfiguration {
      # Package set with our overlays applied
      inherit pkgs;

      # Combine base modules with profile-specific modules
      modules = modules' ++ mods;

      # Make inputs and platform info available in all modules
      # Allows modules to access: inputs.niri-flake, isDarwin, etc.
      extraSpecialArgs = { inherit inputs isDarwin; };
    };
in
# =============================================================================
# HOME MANAGER PROFILES
# =============================================================================
# Each profile represents a complete user environment configuration
# Profiles can be switched between without affecting system config
#
# PLATFORM-SPECIFIC PROFILES:
# - Linux: default, niri
# - macOS: default-darwin, aerospace
# =============================================================================
if isDarwin then
# =============================================================================
# MACOS (DARWIN) PROFILES
# =============================================================================
{
  # ---------------------------------------------------------------------------
  # DEFAULT-DARWIN PROFILE
  # ---------------------------------------------------------------------------
  # Minimal user configuration for macOS without window manager
  #
  # INCLUDES:
  # - Core programs (git, zsh, alacritty, nvim, vscode, etc.)
  # - Shell configuration and scripts
  # - Development tools
  #
  # USE CASES:
  # - Server/headless macOS environments
  # - Testing user config without window manager
  # - Remote SSH development
  # - Base for creating new custom profiles
  #
  # SWITCH TO:
  #   home-manager switch --flake .#default-darwin
  # ---------------------------------------------------------------------------
  default-darwin = mkProfile {
    mods = [ ../home/shared ];
  };

  # ---------------------------------------------------------------------------
  # AEROSPACE PROFILE
  # ---------------------------------------------------------------------------
  # Full desktop environment with Aerospace tiling window manager
  #
  # INCLUDES:
  # - Everything from 'default-darwin' profile (via import)
  # - Aerospace window manager configuration
  # - macOS-optimized desktop utilities
  # - Keyboard-driven workflow tools
  #
  # SYSTEM REQUIREMENTS:
  # - Aerospace installed via Homebrew (handled by homebrew.nix)
  # - macOS accessibility permissions for Aerospace
  #
  # USE CASES:
  # - Tiling window manager workflow on macOS
  # - Keyboard-driven desktop environment
  # - Productivity-focused setup
  #
  # SWITCH TO:
  #   home-manager switch --flake .#aerospace
  #
  # AFTER SWITCHING:
  #   Grant accessibility permissions to Aerospace in System Settings
  # ---------------------------------------------------------------------------
  aerospace = mkProfile {
    mods = [ ../home/wm/aerospace ];
  };

  # ---------------------------------------------------------------------------
  # ADDING NEW MACOS PROFILES
  # ---------------------------------------------------------------------------
  # To create a new macOS profile:
  #
  # 1. Create profile directory: home/wm/<profile-name>/
  # 2. Create default.nix that imports ../shared
  # 3. Add profile-specific modules and packages
  # 4. Add entry here in the isDarwin section
  #
  # PROFILE EXAMPLES:
  # - yabai: Alternative tiling WM
  # - rectangle: Simple window management
  # - minimal-darwin: Absolute minimal macOS setup
  # ---------------------------------------------------------------------------
}
else
# =============================================================================
# LINUX PROFILES
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
  default = mkProfile {
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
  niri = mkProfile {
    mods = [ ../home/wm/niri ];
  };

  hyprland = mkProfile {
    mods = [ ../home/wm/hyprland ];
  };
  # ---------------------------------------------------------------------------
  # To create a new Linux profile:
  #
  # 1. Create profile directory: home/<profile-name>/
  # 2. Create default.nix that imports base config
  # 3. Add profile-specific modules and packages
  # 4. Add entry here in the Linux section:
  #
  #   myprofile = mkProfile {
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
