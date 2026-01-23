# =============================================================================
# FLAKE SCHEMA DEFINITIONS
# =============================================================================
# Defines metadata schemas for custom flake outputs
# Schemas improve discoverability and provide better tooling integration
#
# WHAT ARE FLAKE SCHEMAS?
# - Metadata describing the structure and purpose of flake outputs
# - Enable better documentation generation
# - Improve IDE and CLI tool integration
# - Provide validation for flake structure
#
# INTEGRATION:
# - Merged with standard schemas in flake.nix outputs.schemas
# - Consumed by nix flake show and other introspection tools
#
# CUSTOM OUTPUTS:
# - This configuration exports a custom "out" attribute
# - Contains pkgs and overlays for external consumption
# - Schema describes what "out" contains and how to use it
# =============================================================================
{ flake-schemas }:

{
  # ---------------------------------------------------------------------------
  # "OUT" OUTPUT SCHEMA
  # ---------------------------------------------------------------------------
  # Defines the schema for the custom "out" flake output
  #
  # PURPOSE:
  # The "out" output exports pkgs and overlays for other flakes to use
  # This allows external projects to:
  # - Use our customized package set
  # - Apply our overlays to their nixpkgs
  # - Access our builder functions
  #
  # USAGE BY EXTERNAL FLAKES:
  #   inputs.asthenia.url = "path:/path/to/this/flake";
  #   ...
  #   pkgs = import nixpkgs {
  #     overlays = [ asthenia.out.overlays ];
  #   };
  # ---------------------------------------------------------------------------
  out = {
    # Schema version (for future compatibility)
    version = 1;
    
    # Human-readable description of this output
    doc = ''
      Exports custom attrsets like `pkgs` and `overlays` instances to be used externally.
      
      This output provides:
      - pkgs: A customized nixpkgs with our overlays applied
      - overlays: Our overlay functions for extending nixpkgs
      
      External flakes can consume these to gain access to:
      - Custom library functions (lib.exe)
      - Builder functions (mkHome, mkNixos)
      - Niri unstable package
    '';
    
    # Inventory function: Describes each attribute in the output
    # This generates schema entries for each child attribute (pkgs, overlays)
    inventory = output:
      flake-schemas.lib.mkChildren (builtins.mapAttrs
        (_: _: {
          what = "custom instance to be used by consumers of this flake";
        })
        output);
  };
}
