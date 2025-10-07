{ lib, pkgs, system }:

{
  apply = import ./apply.nix { inherit lib pkgs system; };
  build = import ./build.nix { inherit lib pkgs system; };
  build-switch = import ./build-switch.nix { inherit lib pkgs system; };
  clean = import ./clean.nix { inherit lib pkgs system; };
  rollback = import ./rollback.nix { inherit lib pkgs system; };
}