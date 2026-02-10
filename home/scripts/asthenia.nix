{ writeShellScriptBin, ... }:

writeShellScriptBin "asthenia" ''
  set -e

  FLAKE_DIR="$HOME/.config/asthenia"

  # Detect platform and set defaults
  detect_platform() {
    case "$(uname -s)" in
      Darwin)
        PLATFORM="darwin"
        HOSTNAME="esoteric"
        DEFAULT_HM_PROFILE="aerospace"
        ;;
      Linux)
        PLATFORM="linux"
        HOSTNAME="arasaka"
        DEFAULT_HM_PROFILE="hyprland"
        ;;
      *)
        echo "Error: Unsupported platform $(uname -s)"
        exit 1
        ;;
    esac
  }

  # Detect current Home Manager profile by checking the current generation
  detect_hm_profile() {
    local current_gen="$HOME/.local/state/nix/profiles/home-manager"
    if [[ -L "$current_gen" ]]; then
      # Extract profile name from the generation path
      local profile_path=$(readlink -f "$current_gen")
      if [[ "$profile_path" =~ homeConfigurations\.([^/]+) ]]; then
        echo "''${BASH_REMATCH[1]}"
        return 0
      fi
    fi

    # Default based on platform
    echo "$DEFAULT_HM_PROFILE"
  }

  show_help() {
    cat << EOF
asthenia - NixOS/Darwin and Home Manager rebuild helper

Usage:
  asthenia [OPTIONS]

Options:
  --switch system         Rebuild and switch system configuration
                          (NixOS on Linux, nix-darwin on macOS)
  --switch hm [PROFILE]   Rebuild and switch Home Manager configuration
                          (auto-detects current profile if not specified)
  --switch all [PROFILE]  Rebuild and switch both system and Home Manager
  --update                Update flake inputs before switching
  --help                  Show this help message

Examples:
  asthenia --switch system          # Switch system config (NixOS or Darwin)
  asthenia --switch hm              # Switch Home Manager (auto-detect profile)
  asthenia --switch hm niri         # Switch Home Manager to niri profile
  asthenia --switch hm aerospace    # Switch Home Manager to aerospace profile
  asthenia --switch all             # Switch both (auto-detect HM profile)
  asthenia --update --switch all    # Update inputs, then switch both

Note: Run as a regular user (sudo is called automatically when needed)
EOF
  }

  # Initialize platform detection
  detect_platform

  UPDATE=false
  SWITCH_SYSTEM=false
  SWITCH_HM=false
  HM_PROFILE=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      --switch)
        case $2 in
          system|nixos|darwin)
            SWITCH_SYSTEM=true
            shift 2
            ;;
          hm)
            SWITCH_HM=true
            shift 2
            # Check if next arg is a profile name (not a flag)
            if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
              HM_PROFILE="$1"
              shift
            fi
            ;;
          all)
            SWITCH_SYSTEM=true
            SWITCH_HM=true
            shift 2
            # Check if next arg is a profile name (not a flag)
            if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
              HM_PROFILE="$1"
              shift
            fi
            ;;
          *)
            echo "Error: Invalid switch target '$2'"
            echo "Valid targets: system, hm, all"
            exit 1
            ;;
        esac
        ;;
      --update)
        UPDATE=true
        shift
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        echo "Error: Unknown option '$1'"
        show_help
        exit 1
        ;;
    esac
  done

  # If no action specified, show help
  if [[ "$SWITCH_SYSTEM" == false && "$SWITCH_HM" == false ]]; then
    show_help
    exit 0
  fi

  # Update flake inputs if requested
  if [[ "$UPDATE" == true ]]; then
    echo "Updating flake inputs..."
    cd "$FLAKE_DIR"
    nix flake update
  fi

  # Switch system configuration
  if [[ "$SWITCH_SYSTEM" == true ]]; then
    case "$PLATFORM" in
      darwin)
        echo "Switching Darwin configuration ($HOSTNAME)..."
        sudo darwin-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME"
        ;;
      linux)
        echo "Switching NixOS configuration ($HOSTNAME)..."
        sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME"
        ;;
    esac
  fi

  # Switch Home Manager
  if [[ "$SWITCH_HM" == true ]]; then
    # Auto-detect profile if not specified
    if [[ -z "$HM_PROFILE" ]]; then
      HM_PROFILE=$(detect_hm_profile)
      echo "Detected Home Manager profile: $HM_PROFILE"
    fi

    echo "Switching Home Manager configuration ($HM_PROFILE)..."
    home-manager switch --flake "$FLAKE_DIR#$HM_PROFILE"
  fi

  echo "Done!"
''
