{ lib, pkgs, system }:

let
  colors = {
    red = "\\033[1;31m";
    green = "\\033[1;32m";
    yellow = "\\033[1;33m";
    nc = "\\033[0m";
  };

in pkgs.writeShellScriptBin "clean" ''
  set -e

  RED='${colors.red}'
  GREEN='${colors.green}'
  YELLOW='${colors.yellow}'
  NC='${colors.nc}'

  echo -e "''${YELLOW}Cleaning up old system generations...''${NC}"

  # Clean up old generations (older than 7 days)
  sudo ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 7d

  echo -e "''${GREEN}Cleanup complete!''${NC}"
''