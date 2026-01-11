# =============================================================================
# CUSTOM LIBRARY FUNCTIONS
# =============================================================================
# This module provides utility functions that extend nixpkgs.lib
# These functions are made available throughout the configuration via overlays
#
# INTEGRATION:
# - Imported by lib/overlays.nix
# - Extended into pkgs.lib via libOverlay
# - Available as lib.exe, lib.removeNewline, lib.secretManager everywhere
#
# USAGE EXAMPLES:
# - lib.exe pkgs.zsh => "/nix/store/.../bin/zsh"
# - lib.removeNewline fileContents
# - lib.secretManager.readSecret "~/.secrets/token"
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

  # ---------------------------------------------------------------------------
  # STRING CLEANING UTILITIES
  # ---------------------------------------------------------------------------
  # Removes trailing newline character from strings
  #
  # USE CASES:
  # - Cleaning output from readFile that includes trailing newlines
  # - Processing command output that ends with \n
  # - Preparing strings for concatenation
  #
  # PARAMETERS:
  # - str: String to clean
  #
  # RETURNS:
  # - String without trailing newline
  #
  # EXAMPLE:
  #   lib.removeNewline "hello\n" => "hello"
  # ---------------------------------------------------------------------------
  removeNewline = str: lib.strings.removeSuffix "\n" str;

  # ---------------------------------------------------------------------------
  # SECRET MANAGEMENT
  # ---------------------------------------------------------------------------
  # Provides functions for reading secrets from files
  #
  # SECURITY CONSIDERATIONS:
  # - Secrets read this way are stored in the Nix store (world-readable!)
  # - Only use for non-critical secrets or during development
  # - For production, consider: sops-nix, agenix, or vault integration
  #
  # USAGE:
  #   programs.git.userEmail = lib.secretManager.readSecret "./secrets/email";
  #
  # FUTURE ENHANCEMENTS:
  # - Could integrate with sops-nix for encrypted secrets
  # - Could add runtime secret injection via systemd
  # ---------------------------------------------------------------------------
  secretManager = {
    # Read a secret from a file path
    # WARNING: Result will be in Nix store (world-readable)
    readSecret = path: builtins.readFile path;
  };
}
