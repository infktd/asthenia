# =============================================================================
# NIX-DARWIN SYSTEM CONFIGURATION BUILDER
# =============================================================================
# This module creates nix-darwin system configurations (macOS machine-level configs)
# Called by pkgs.builders.mkDarwin in lib/overlays.nix
#
# MULTI-MACHINE ARCHITECTURE:
# - One configuration per physical macOS machine
# - Shared base config could be added (system/darwin-configuration.nix)
# - Machine-specific overrides (system/machine/<hostname>/)
# - Enables managing multiple Macs from single flake
#
# SYSTEM VS USER:
# - This file: System-level (nix settings, homebrew, system defaults)
# - outputs/hm.nix: User-level (dotfiles, programs, themes)
# - Both work together but update independently
#
# USAGE:
# - Build: nix build .#darwinConfigurations.<hostname>.system
# - Switch: darwin-rebuild switch --flake .#<hostname>
# =============================================================================
{ extraSystemConfig, inputs, system, pkgs, ... }:

let
  # Import darwinSystem builder from nix-darwin
  inherit (inputs.nix-darwin.lib) darwinSystem;

  # Import lib from our custom pkgs (includes our overlays)
  inherit (pkgs) lib;

  # ---------------------------------------------------------------------------
  # MACHINE HOSTNAMES
  # ---------------------------------------------------------------------------
  # List of macOS machine hostnames to build configurations for
  # Each hostname must have a corresponding directory: system/machine/<hostname>/
  #
  # CURRENT MACHINES:
  # - esoteric: MacBook with Apple Silicon (aarch64-darwin)
  #
  # ADDING NEW MACHINES:
  # 1. Add hostname to this list
  # 2. Create system/machine/<hostname>/
  # 3. Add default.nix with darwin-specific config
  # 4. Rebuild: darwin-rebuild switch --flake .#<hostname>
  # ---------------------------------------------------------------------------
  hosts = [ "esoteric" ];

  # ---------------------------------------------------------------------------
  # BASE MODULES
  # ---------------------------------------------------------------------------
  # These modules are included in EVERY nix-darwin configuration
  #
  # 1. Extra config: Allows callers to inject additional modules
  # 2. Nix registry: Pins nixpkgs for imperative nix commands
  #
  # MODULE LOADING ORDER:
  # - Base modules loaded first
  # - Machine-specific modules loaded last (can override base)
  # - Later modules can override earlier ones
  # ---------------------------------------------------------------------------
  modules' = [
    # Allow additional modules to be injected from caller
    extraSystemConfig

    # Pin nixpkgs registry to our flake input version
    # Makes 'nix run nixpkgs#...' use the same version as system
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
  ];

  # ---------------------------------------------------------------------------
  # CONFIGURATION BUILDER
  # ---------------------------------------------------------------------------
  # Creates a nix-darwin system configuration for a given hostname
  #
  # PROCESS:
  # 1. Takes a hostname string (e.g., "esoteric")
  # 2. Creates an attribute set: { esoteric = <darwin-config>; }
  # 3. Loads base modules + machine-specific modules
  # 4. Passes special args (inputs) to all modules
  #
  # MACHINE-SPECIFIC MODULES:
  # Located at: system/machine/${host}/
  # Must contain at minimum:
  # - default.nix: Machine configuration
  #
  # PARAMETERS AVAILABLE IN MODULES:
  # - config: Current system configuration state
  # - lib: Extended nixpkgs lib with our custom functions
  # - pkgs: Package set with our overlays applied
  # - inputs: Flake inputs (home-manager, etc.)
  # ---------------------------------------------------------------------------
  make = host: {
    ${host} = darwinSystem {
      # Pass our extended lib and pkgs to all modules
      inherit lib pkgs;

      # Make flake inputs available as 'inputs' argument in modules
      # Allows importing upstream modules: inputs.home-manager.darwinModules.home-manager
      specialArgs = { inherit inputs; };

      # Combine base modules with machine-specific modules
      # Machine modules loaded last, so they can override base settings
      modules = modules' ++ [ ../system/machine/${host} ];
    };
  };
in
# =============================================================================
# SYSTEM CONFIGURATIONS OUTPUT
# =============================================================================
# Merge all individual machine configs into a single attribute set
# Result: { esoteric = <config>; <other-machine> = <config>; ... }
#
# HOW IT WORKS:
# 1. map make hosts: Apply 'make' to each hostname
#    Result: [ { esoteric = ...; } { other-machine = ...; } ]
# 2. lib.mergeAttrsList: Merge list of attr sets into one
#    Result: { esoteric = ...; other-machine = ...; }
#
# USAGE:
#   nix build .#darwinConfigurations.esoteric.system
#   darwin-rebuild switch --flake .#esoteric
# =============================================================================
lib.mergeAttrsList (map make hosts)
