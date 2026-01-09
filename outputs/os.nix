{ extraSystemConfig, inputs, system, pkgs, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (pkgs) lib;

  # List of machine hostnames to build configurations for
  hosts = [ "arasaka" ];

  # Base modules for all NixOS configurations
  modules' = [
    ../system/configuration.nix
    extraSystemConfig
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
  ];

  # Helper to create a NixOS configuration for a given host
  make = host: {
    ${host} = nixosSystem {
      inherit lib pkgs system;
      specialArgs = { inherit inputs; };
      modules = modules' ++ [ ../system/machine/${host} ];
    };
  };
in
# Merge all host configurations into a single attribute set
lib.mergeAttrsList (map make hosts)
