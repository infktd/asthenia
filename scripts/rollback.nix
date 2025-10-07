{ lib, pkgs, system }:

let
  colors = {
    red = "\\033[1;31m";
    green = "\\033[1;32m";
    yellow = "\\033[1;33m";
    nc = "\\033[0m";
  };

in pkgs.writeShellScriptBin "rollback" ''
  set -e

  GREEN='${colors.green}'
  YELLOW='${colors.yellow}'
  RED='${colors.red}'
  NC='${colors.nc}'

  FLAKE="macos"

  echo -e "''${YELLOW}Available generations:''${NC}"
  /run/current-system/sw/bin/darwin-rebuild --list-generations

  echo -e "''${YELLOW}Enter the generation number for rollback:''${NC}"
  read GEN_NUM

  if [ -z "$GEN_NUM" ]; then
    echo -e "''${RED}No generation number entered. Aborting rollback.''${NC}"
    exit 1
  fi

  echo -e "''${YELLOW}Rolling back to generation $GEN_NUM...''${NC}"
  /run/current-system/sw/bin/darwin-rebuild switch --flake .#$FLAKE --switch-generation $GEN_NUM

  echo -e "''${GREEN}Rollback to generation $GEN_NUM complete!''${NC}"
''