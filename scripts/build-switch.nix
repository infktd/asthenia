{ lib, pkgs, system }:

let
  colors = {
    red = "\\033[1;31m";
    green = "\\033[1;32m";
    yellow = "\\033[1;33m";
    nc = "\\033[0m";
  };

  systemType = if pkgs.stdenv.isDarwin then system else "x86_64-linux";

in pkgs.writeShellScriptBin "build-switch" ''
  set -e

  GREEN='${colors.green}'
  YELLOW='${colors.yellow}'
  RED='${colors.red}'
  NC='${colors.nc}'

  SYSTEM_TYPE="${systemType}"
  FLAKE_SYSTEM="darwinConfigurations.''${SYSTEM_TYPE}.system"

  export NIXPKGS_ALLOW_UNFREE=1

  ${if pkgs.stdenv.isDarwin then ''
    echo -e "''${YELLOW}Starting build...''${NC}"
    ${pkgs.nix}/bin/nix --extra-experimental-features 'nix-command flakes' build .#$FLAKE_SYSTEM "$@"

    echo -e "''${YELLOW}Switching to new generation...''${NC}"
    # See https://github.com/nix-darwin/nix-darwin/issues/1457 on why we need sudo
    sudo ./result/sw/bin/darwin-rebuild switch --flake .#''${SYSTEM_TYPE} "$@"

    echo -e "''${YELLOW}Cleaning up...''${NC}"
    ${pkgs.coreutils}/bin/unlink ./result

    echo -e "''${GREEN}Switch to new generation complete!''${NC}"
  '' else ''
    # Parse arguments for --host parameter
    HOST=""
    OTHER_ARGS=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --host=*)
          HOST="''${1#*=}"
          shift
          ;;
        --host)
          HOST="$2"
          shift 2
          ;;
        *)
          OTHER_ARGS="$OTHER_ARGS $1"
          shift
          ;;
      esac
    done

    # If host is specified, use it directly
    if [ -n "$HOST" ]; then
      FLAKE_TARGET="$HOST"
      echo -e "''${YELLOW}Building for named host: $HOST''${NC}"
    else
      # Default behavior: detect system architecture
      SYSTEM=$(${pkgs.coreutils}/bin/uname -m)
      
      case "$SYSTEM" in
        x86_64)
          FLAKE_TARGET="x86_64-linux"
          ;;
        aarch64)
          FLAKE_TARGET="aarch64-linux"
          ;;
        *)
          echo -e "''${RED}Unsupported architecture: $SYSTEM''${NC}"
          exit 1
          ;;
      esac
      echo -e "''${YELLOW}Building for platform: $FLAKE_TARGET''${NC}"
    fi

    echo -e "''${YELLOW}Starting...''${NC}"

    # We pass SSH from user to root so root can download secrets from our private Github
    sudo SSH_AUTH_SOCK=$SSH_AUTH_SOCK /run/current-system/sw/bin/nixos-rebuild switch --flake .#$FLAKE_TARGET $OTHER_ARGS

    echo -e "''${GREEN}Switch to new generation complete!''${NC}"
  ''}
''