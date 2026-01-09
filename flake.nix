{
  description = "NixOS Configuration with Home Manager";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    # Use shallow clone for faster updates
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake schemas for better flake documentation
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";

    # Niri window manager
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nvf (neovim)
    nvf = {
      url = "github:notashelf/nvf";
    };

    # nixcord (Discord)
    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    # dankmaterialshell (quickshell)
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, flake-schemas, ... }:
    let
      # Import user-configurable variables
      vars = import ./variables.nix;
      
      system = vars.system.architecture;

      # Import overlays from lib/
      overlays = import ./lib/overlays.nix { inherit inputs system vars; };

      # Configure pkgs with overlays
      pkgs = import nixpkgs {
        inherit overlays system;
        config = {
          allowUnfree = vars.advanced.allowUnfree;
        };
      };
    in
    {
      # Home Manager configurations
      # Build with: nix build .#homeConfigurations.<name>.activationPackage
      homeConfigurations = pkgs.builders.mkHome { inherit vars; };

      # NixOS system configurations
      # Build with: sudo nixos-rebuild switch --flake .#<hostname>
      nixosConfigurations = pkgs.builders.mkNixos { inherit vars; };

      # Export pkgs, overlays, and variables for external use
      out = { inherit pkgs overlays vars; };

      # Flake schemas for documentation
      schemas =
        flake-schemas.schemas //
        import ./lib/schemas.nix { inherit (inputs) flake-schemas; };
    };
}