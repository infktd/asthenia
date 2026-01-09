{ writeShellScriptBin, ... }:

writeShellScriptBin "asthenia" ''
  set -e

  FLAKE_DIR="$HOME/Projects/acidBurn"
  HOSTNAME="arasaka"
  
  # Detect current Home Manager profile by checking the current generation
  detect_hm_profile() {
    local current_gen="$HOME/.local/state/nix/profiles/home-manager"
    if [[ -L "$current_gen" ]]; then
      # Extract profile name from the generation path
      local profile_path=$(readlink -f "$current_gen")
      if [[ "$profile_path" =~ homeConfigurations\.([^/]+) ]]; then
        echo "''${BASH_     Rebuild and switch NixOS system configuration
    --switch hm [PROFILE]   Rebuild and switch Home Manager configuration
                            (auto-detects current profile if not specified)
    --switch all [PROFILE]  Rebuild and switch both NixOS and Home Manager
    --update                Update flake inputs before switching
    --help                  Show this help message
  
  Examples:
    asthenia --switch nixos           # Switch NixOS only
    asthenia --switch hm              # Switch Home Manager (auto-detect profile)
    asthenia --switch hm niri         # Switch Home Manager to niri profile
    asthenia --switch all             # Switch both (auto-detect HM profile)
    asthenia --update --switch all    # Update inputs, then switch both
    
  Note: Run as a regular user (sudo is called automatically when needed)
  asthenia - NixOS and Home Manager rebuild helper
  
  Usage:
    asthenia [OPTIONS]
  
  Options:
    --switch nixos     Rebuild and switch NixOS system configuration
    --switch hm        Rebuild and switch Home Manager configuration
    --switch all       Rebuild and switch both NixOS and Home Manager
    --update           Update flake inputs before switching
    --help             Show this help message
  
  Examples:
    asthenia --switch nixos        # Switch NixOS only
    asthenia --switch hm           # Switch Home Manager only
    asthenia --switch all          # Switch both
    asthenia --update --switch all # Update inputs, then switch both
  EOF
  }
  HM_PROFILE=""
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      --switch)
        case $2 in
          nixos)
            SWITCH_NIXOS=true
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
            SWITCH_NIXOS=true
            SWITCH_HM=true
            shift 2
            # Check if next arg is a profile name (not a flag)
            if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
              HM_PROFILE="$1"
              shift
            fi
          all)
            SWITCH_NIXOS=true
            SWITCH_HM=true
            shift 2
            ;;
          *)
            echo "Error: Invalid switch target '$2'"
            echo "Valid targets: nixos, hm, all"
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
  if [[ "$SWITCH_NIXOS" == false && "$SWITCH_HM" =$HOSTNAME"
  fi
  
  # Switch Home Manager
  if [[ "$SWITCH_HM" == true ]]; then
    # Auto-detect profile if not specified
    if [[ -z "$HM_PROFILE" ]]; then
      HM_PROFILE=$(detect_hm_profile)
      echo "📍 Detected Home Manager profile: $HM_PROFILE"
    fi
    
    echo "🏠 Switching Home Manager configuration..."
    home-manager switch --flake "$FLAKE_DIR#$HM_PROFILE
    echo "🔄 Updating flake inputs..."
    cd "$FLAKE_DIR"
    nix flake update
  fi
  
  # Switch NixOS
  if [[ "$SWITCH_NIXOS" == true ]]; then
    echo "🔧 Switching NixOS configuration..."
    sudo nixos-rebuild switch --flake "$FLAKE_DIR#arasaka"
  fi
  
  # Switch Home Manager
  if [[ "$SWITCH_HM" == true ]]; then
    echo "🏠 Switching Home Manager configuration..."
    home-manager switch --flake "$FLAKE_DIR#niri"
  fi
  
  echo "✅ Done!"
''
