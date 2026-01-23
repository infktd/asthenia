# =============================================================================
# CUSTOM LIBRARY FUNCTIONS
# =============================================================================
# This module provides utility functions that extend nixpkgs.lib
# These functions are made available throughout the configuration via overlays
#
# INTEGRATION:
# - Imported by lib/overlays.nix
# - Extended into pkgs.lib via libOverlay
# - Available as lib.exe everywhere
#
# USAGE EXAMPLE:
# - lib.exe pkgs.zsh => "/nix/store/.../bin/zsh"
# =============================================================================
{ lib }:

{
  # ---------------------------------------------------------------------------
  # EXECUTABLE PATH EXTRACTION
  # ---------------------------------------------------------------------------
  # Extracts the full path to a package's main executable
  #
  # WHY THIS EXISTS:
  # - Nix packages don't have predictable binary names
  # - Some packages use pname, others use name
  # - This provides a consistent way to get the executable path
  #
  # PARAMETERS:
  # - pkg: A derivation (package) from nixpkgs
  #
  # RETURNS:
  # - Full path to the package's main executable
  #
  # EXAMPLE:
  #   lib.exe pkgs.fish => "/nix/store/xxx-fish-3.6.0/bin/fish"
  #   Used in: sessionVariables.SHELL = "${lib.exe pkgs.zsh}";
  # ---------------------------------------------------------------------------
  exe = pkg: "${lib.getBin pkg}/bin/${pkg.pname or pkg.name}";
}
