{
  description = "Asthenia - NixOS & Darwin Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://claude-code.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-darwin = { url = "github:LnL7/nix-darwin"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    niri-flake = { url = "github:sodiboo/niri-flake"; inputs.nixpkgs.follows = "nixpkgs"; };
    dms = { url = "github:AvengeMedia/DankMaterialShell"; };
    hyprland = { url = "github:hyprwm/Hyprland"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixcord = { url = "github:kaylorben/nixcord"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    claude-code = { url = "github:sadjow/claude-code-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nix-darwin, flake-schemas, ... }:
    let
      mkPkgs = system: import nixpkgs {
        inherit system;
        overlays = [
          inputs.niri-flake.overlays.niri
          inputs.claude-code.overlays.default
          (final: prev: {
            lib = (prev.lib.extend (_: _: {
              exe = pkg: "${prev.lib.getBin pkg}/bin/${pkg.pname or pkg.name}";
            })).extend (import "${nixpkgs}/lib/flake-version-info.nix" nixpkgs);
          })
        ];
        config.allowUnfree = true;
      };

      linuxPkgs = mkPkgs "x86_64-linux";
      darwinPkgs = mkPkgs "aarch64-darwin";

      mkHome = { pkgs, isDarwin ? false, modules }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            { nix.registry.nixpkgs.flake = nixpkgs; }
            inputs.sops-nix.homeManagerModules.sops
          ] ++ modules;
          extraSpecialArgs = { inherit inputs isDarwin; };
        };
    in
    {
      homeConfigurations = {
        default        = mkHome { pkgs = linuxPkgs;  modules = [ ./home ]; };
        niri           = mkHome { pkgs = linuxPkgs;  modules = [ ./home ./home/desktop/niri ]; };
        hyprland       = mkHome { pkgs = linuxPkgs;  modules = [ ./home ./home/desktop/hyprland.nix ]; };
        default-darwin = mkHome { pkgs = darwinPkgs; isDarwin = true; modules = [ ./home ]; };
        aerospace      = mkHome { pkgs = darwinPkgs; isDarwin = true; modules = [ ./home ./home/desktop/aerospace ]; };
      };

      nixosConfigurations.arasaka = nixpkgs.lib.nixosSystem {
        inherit (linuxPkgs) lib;
        pkgs = linuxPkgs;
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.sops-nix.nixosModules.sops
          { nix.registry.nixpkgs.flake = nixpkgs; }
          ./machines/arasaka/hardware-configuration.nix
          ./nixos/base.nix
          ./nixos/nvidia.nix
          ./nixos/gaming.nix
          ./nixos/niri.nix
          { networking.hostName = "arasaka"; }
        ];
      };

      darwinConfigurations.esoteric = nix-darwin.lib.darwinSystem {
        inherit (darwinPkgs) lib;
        pkgs = darwinPkgs;
        specialArgs = { inherit inputs; };
        modules = [
          { nix.registry.nixpkgs.flake = nixpkgs; }
          ./darwin.nix
          { networking = { computerName = "esoteric"; hostName = "esoteric"; localHostName = "esoteric"; }; }
        ];
      };

      schemas = flake-schemas.schemas;
    };
}
