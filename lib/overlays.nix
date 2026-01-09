{ inputs, system, vars }:

let
  # Version overlay for nixos-version to work with flakes
  libVersionOverlay = import "${inputs.nixpkgs}/lib/flake-version-info.nix" inputs.nixpkgs;

  # Extend lib with custom functions
  libOverlay = f: p: rec {
    libx = import ./. { inherit (p) lib; };
    lib = (p.lib.extend (_: _: {
      inherit (libx) exe removeNewline secretManager;
    })).extend libVersionOverlay;
  };

  # Main overlays - add custom packages and modifications here
  overlays = f: p: {
    # Builder functions for creating Home Manager and NixOS configurations
    builders = {
      mkHome = { pkgs ? f, extraHomeConfig ? { }, vars ? {} }:
        import ../outputs/hm.nix { inherit extraHomeConfig inputs pkgs system vars; };

      mkNixos = { pkgs ? f, extraSystemConfig ? { }, vars ? {} }:
        import ../outputs/os.nix { inherit extraSystemConfig inputs pkgs system vars; };
    };
  };
in
[
  libOverlay
  overlays
  inputs.niri-flake.overlays.niri
]
