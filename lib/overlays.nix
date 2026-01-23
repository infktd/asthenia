# =============================================================================
# NIXPKGS OVERLAYS
# =============================================================================
# Overlays modify and extend the nixpkgs package set
# They allow us to add custom packages, modify existing ones, and inject utilities
#
# OVERLAY ARCHITECTURE:
# 1. libOverlay: Extends pkgs.lib with lib.exe utility function
# 2. overlays: Adds builder functions for creating configurations
#
# HOW OVERLAYS WORK:
# - f (final): The final package set after all overlays are applied
# - p (prev): The previous package set before this overlay
# - Overlays are applied in order, creating a chain of modifications
#
# USAGE:
# - These overlays are imported in flake.nix and applied to nixpkgs
# - Results in pkgs.lib.exe, pkgs.builders.mkHome, etc. being available
# =============================================================================
{ inputs, system }:

let
  # ---------------------------------------------------------------------------
  # VERSION OVERLAY
  # ---------------------------------------------------------------------------
  # Enables nixos-version command to work correctly with flakes
  # Without this, nixos-version would show "<unknown>" for the system version
  #
  # This overlay adds version metadata from the flake to lib
  # It's required for proper version tracking in flake-based systems
  # ---------------------------------------------------------------------------
  libVersionOverlay = import "${inputs.nixpkgs}/lib/flake-version-info.nix" inputs.nixpkgs;

  # ---------------------------------------------------------------------------
  # LIBRARY EXTENSION OVERLAY
  # ---------------------------------------------------------------------------
  # Extends pkgs.lib with our custom utility functions
  #
  # WHAT IT DOES:
  # 1. Imports ./default.nix (our custom lib functions)
  # 2. Extends pkgs.lib to include: exe
  # 3. Applies version overlay for nixos-version support
  #
  # RESULT:
  # - All Nix files can use lib.exe
  # - Version information is properly tracked
  #
  # OVERLAY PATTERN:
  # - rec: Makes libx available within this overlay scope
  # - lib.extend: Extends the existing lib without replacing it
  # ---------------------------------------------------------------------------
  libOverlay = f: p: rec {
    # Import our custom library functions
    libx = import ./. { inherit (p) lib; };
    
    # Extend nixpkgs lib with our custom functions and version info
    lib = (p.lib.extend (_: _: {
      inherit (libx) exe;
    })).extend libVersionOverlay;
  };

  # ---------------------------------------------------------------------------
  # BUILDER FUNCTIONS OVERLAY
  # ---------------------------------------------------------------------------
  # Adds configuration builder functions to pkgs.builders
  #
  # ARCHITECTURE DECISION:
  # Why use builders instead of direct imports?
  # - Allows parameterization of configurations
  # - Enables configuration reuse with different parameters
  # - Provides consistent interface for creating configs
  # - Makes it easy to override settings per-machine or per-user
  #
  # BUILDERS AVAILABLE:
  # - pkgs.builders.mkHome: Creates Home Manager configurations
  # - pkgs.builders.mkNixos: Creates NixOS system configurations
  #
  # USAGE IN FLAKE.NIX:
  #   homeConfigurations = pkgs.builders.mkHome { };
  #   nixosConfigurations = pkgs.builders.mkNixos { };
  # ---------------------------------------------------------------------------
  overlays = f: p: {
    # Builder functions for creating Home Manager and NixOS configurations
    builders = {
      # --- HOME MANAGER BUILDER ---
      # Creates user-level configurations (dotfiles, programs, themes)
      #
      # PARAMETERS:
      # - pkgs: Package set to use (defaults to final overlay pkgs)
      # - extraHomeConfig: Additional modules to merge into all profiles
      #
      # RETURNS: Attribute set of Home Manager configurations
      #   { default = ...; niri = ...; }
      #
      # IMPLEMENTATION: See outputs/hm.nix for profile definitions
      mkHome = { pkgs ? f, extraHomeConfig ? { } }:
        import ../outputs/hm.nix { inherit extraHomeConfig inputs pkgs system; };

      # --- NIXOS SYSTEM BUILDER ---
      # Creates system-level configurations (kernel, drivers, services)
      #
      # PARAMETERS:
      # - pkgs: Package set to use (defaults to final overlay pkgs)
      # - extraSystemConfig: Additional modules to merge into all systems
      #
      # RETURNS: Attribute set of NixOS configurations
      #   { arasaka = ...; <other-machines> = ...; }
      #
      # IMPLEMENTATION: See outputs/os.nix for system definitions
      mkNixos = { pkgs ? f, extraSystemConfig ? { } }:
        import ../outputs/os.nix { inherit extraSystemConfig inputs pkgs system; };
    };
  };
in
# =============================================================================
# OVERLAY LIST
# =============================================================================
# Overlays are applied in order:
# 1. libOverlay: Adds lib.exe function
# 2. overlays: Adds builder functions (mkHome, mkNixos)
# 3. niri-flake overlay: Adds niri-unstable package
#
# Each overlay can reference packages and functions from previous overlays
# =============================================================================
[
  libOverlay
  overlays
  inputs.niri-flake.overlays.niri    # Provides pkgs.niri-unstable
  inputs.zed-editor.overlays.default # Provides pkgs.zed-editor (latest from upstream)
]
