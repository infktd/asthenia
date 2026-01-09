{ extraHomeConfig, inputs, system, pkgs, vars, ... }:

let
  # Base modules for all Home Manager configurations
  modules' = [
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
    extraHomeConfig
  ];

  # Helper to create a Home Manager configuration
  mkHome = { hidpi ? false, mutable ? false, mods ? [ ] }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = modules' ++ mods;
      extraSpecialArgs = { inherit inputs vars; };
    };
in
{
  # Default configuration - basic setup without window manager
  default = mkHome {
    mods = [ ../home/shared ];
  };

  # Niri window manager configuration
  niri = mkHome {
    mods = [ ../home/wm/niri ];
  };
}
