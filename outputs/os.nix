# =============================================================================
# NIXOS SYSTEM CONFIGURATION BUILDER
# =============================================================================
# This module creates NixOS system configurations (machine-level configs)
# Called by pkgs.builders.mkNixos in lib/overlays.nix
#
# MULTI-MACHINE ARCHITECTURE:
# - One configuration per physical/virtual machine
# - Shared base config (system/configuration.nix)
# - Machine-specific overrides (system/machine/<hostname>/)
# - Enables managing multiple machines from single flake
#
# SYSTEM VS USER:
# - This file: System-level (kernel, drivers, services, boot)
# - outputs/hm.nix: User-level (dotfiles, programs, themes)
# - Both work together but update independently
#
# USAGE:
# - Build: nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
# - Switch: sudo nixos-rebuild switch --flake .#<hostname>
# - Test: sudo nixos-rebuild test --flake .#<hostname>
# - Boot: sudo nixos-rebuild boot --flake .#<hostname>
# =============================================================================
{ extraSystemConfig, inputs, system, pkgs, ... }:

let
  # Import nixosSystem builder from nixpkgs
  inherit (inputs.nixpkgs.lib) nixosSystem;
  
  # Import lib from our custom pkgs (includes our overlays)
  inherit (pkgs) lib;

  # ---------------------------------------------------------------------------
  # MACHINE HOSTNAMES
  # ---------------------------------------------------------------------------
  # List of machine hostnames to build configurations for
  # Each hostname must have a corresponding directory: system/machine/<hostname>/
  #
  # CURRENT MACHINES:
  # - arasaka: Primary desktop with NVIDIA GPU and Niri WM
  #
  # ADDING NEW MACHINES:
  # 1. Add hostname to this list
  # 2. Create system/machine/<hostname>/
  # 3. Add default.nix and hardware-configuration.nix
  # 4. Rebuild: sudo nixos-rebuild switch --flake .#<hostname>
  # ---------------------------------------------------------------------------
  hosts = [ "arasaka" ];

  # ---------------------------------------------------------------------------
  # BASE MODULES
  # ---------------------------------------------------------------------------
  # These modules are included in EVERY NixOS configuration
  #
  # 1. Base config: Core system settings (boot, networking, users, etc.)
  # 2. Extra config: Allows callers to inject additional modules
  # 3. Nix registry: Pins nixpkgs for imperative nix commands
  #
  # MODULE LOADING ORDER:
  # - Base modules loaded first
  # - Machine-specific modules loaded last (can override base)
  # - Later modules can override earlier ones
  # ---------------------------------------------------------------------------
  modules' = [
    # Base system configuration (shared by all machines)
    ../system/configuration.nix
    
    # Allow additional modules to be injected from caller
    extraSystemConfig
    
    # Pin nixpkgs registry to our flake input version
    # Makes 'nix run nixpkgs#...' use the same version as system
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
  ];

  # ---------------------------------------------------------------------------
  # CONFIGURATION BUILDER
  # ---------------------------------------------------------------------------
  # Creates a NixOS system configuration for a given hostname
  #
  # PROCESS:
  # 1. Takes a hostname string (e.g., "arasaka")
  # 2. Creates an attribute set: { arasaka = <nixos-config>; }
  # 3. Loads base modules + machine-specific modules
  # 4. Passes special args (inputs) to all modules
  #
  # MACHINE-SPECIFIC MODULES:
  # Located at: system/machine/${host}/
  # Must contain at minimum:
  # - default.nix: Machine configuration
  # - hardware-configuration.nix: Hardware detection (use nixos-generate-config)
  #
  # PARAMETERS AVAILABLE IN MODULES:
  # - config: Current system configuration state
  # - lib: Extended nixpkgs lib with our custom functions
  # - pkgs: Package set with our overlays applied
  # - inputs: Flake inputs (niri-flake, dms, nvf, etc.)
  # ---------------------------------------------------------------------------
  make = host: {
    ${host} = nixosSystem {
      # Pass our extended lib and pkgs to all modules
      inherit lib pkgs system;
      
      # Make flake inputs available as 'inputs' argument in modules
      # Allows importing upstream modules: inputs.niri-flake.nixosModules.niri
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
# Result: { arasaka = <config>; <other-machine> = <config>; ... }
#
# HOW IT WORKS:
# 1. map make hosts: Apply 'make' to each hostname
#    Result: [ { arasaka = ...; } { other-machine = ...; } ]
# 2. lib.mergeAttrsList: Merge list of attr sets into one
#    Result: { arasaka = ...; other-machine = ...; }
#
# USAGE:
#   nix build .#nixosConfigurations.arasaka.config.system.build.toplevel
#   sudo nixos-rebuild switch --flake .#arasaka
# =============================================================================
lib.mergeAttrsList (map make hosts)
