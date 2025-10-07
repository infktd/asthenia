{ lib, pkgs, system }:

let
  colors = {
    red = "\\033[1;31m";
    green = "\\033[1;32m";
    yellow = "\\033[1;33m";
    nc = "\\033[0m";
  };

  systemType = if pkgs.stdenv.isDarwin then system else "x86_64-linux";
  flakeSystem = if pkgs.stdenv.isDarwin 
    then "darwinConfigurations.${systemType}.system"
    else "nixosConfigurations.${systemType}";

in pkgs.writeShellScriptBin "build" ''
  set -e

  GREEN='${colors.green}'
  YELLOW='${colors.yellow}'
  RED='${colors.red}'
  NC='${colors.nc}'

  SYSTEM_TYPE="${systemType}"
  FLAKE_SYSTEM="${flakeSystem}"

  export NIXPKGS_ALLOW_UNFREE=1

  echo -e "''${YELLOW}Starting build...''${NC}"
  ${pkgs.nix}/bin/nix --extra-experimental-features 'nix-command flakes' build .#$FLAKE_SYSTEM "$@"

  echo -e "''${YELLOW}Cleaning up...''${NC}"
  ${pkgs.coreutils}/bin/unlink ./result

  echo -e "''${GREEN}Build complete!''${NC}"
''