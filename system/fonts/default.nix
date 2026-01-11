# =============================================================================
# CUSTOM SYSTEM FONTS
# =============================================================================
# This module provides a place to package custom fonts for system-wide use
# Currently empty - fonts are installed directly in configuration.nix
#
# CURRENT FONT SETUP:
# - Nerd Fonts (jetbrains-mono, iosevka) - in configuration.nix
# - Font Awesome - in configuration.nix
# - Additional fonts in home/wm/niri for user-level
#
# WHEN TO ADD FONTS HERE:
# - Custom font files not in nixpkgs
# - Modified/patched fonts
# - Font packages needing special derivations
#
# USAGE EXAMPLE:
# - Add font package: my-font = pkgs.callPackage ./my-font.nix { };
# - Import in configuration.nix: myfonts = pkgs.callPackage fonts/default.nix { };
# - Install: fonts.packages = [ myfonts.my-font ];
# =============================================================================
{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # CUSTOM FONT PACKAGES
  # ---------------------------------------------------------------------------
  # Add custom fonts here if needed
  #
  # Example for a custom font file:
  #   my-custom-font = pkgs.callPackage ./my-custom-font.nix { };
  #
  # Example font derivation (my-custom-font.nix):
  #   { stdenv, fetchurl }:
  #   stdenv.mkDerivation {
  #     pname = "my-custom-font";
  #     version = "1.0";
  #     src = fetchurl {
  #       url = "https://example.com/font.zip";
  #       sha256 = "...";
  #     };
  #     installPhase = ''
  #       mkdir -p $out/share/fonts/truetype
  #       cp *.ttf $out/share/fonts/truetype/
  #     '';
  #   }
  # ---------------------------------------------------------------------------
}
