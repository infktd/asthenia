# =============================================================================
# PROGRAM CONFIGURATIONS
# =============================================================================
# Central import file for all program-specific configurations
# Each program has its own directory with dedicated configuration
#
# STRUCTURE:
# - This file: Imports individual program configs
# - home/programs/<name>/: Dedicated configuration per program
# - Modular approach: Easy to enable/disable programs
#
# CROSS-PLATFORM SUPPORT:
# - Common programs work on both Linux and macOS
# - Linux-only programs (fuzzel, discord via nix) are conditionally imported
# - macOS GUI apps typically installed via Homebrew casks
#
# ADDING NEW PROGRAMS:
# 1. Create directory: home/programs/<program-name>/
# 2. Create config file: home/programs/<program-name>/<program-name>.nix
# 3. Add import here: ../programs/<program-name>/<program-name>.nix
# 4. Rebuild: home-manager switch --flake .#<profile>
#
# PROGRAM CATEGORIES:
# - Shell: zsh (shell configuration and plugins)
# - Terminal: alacritty (terminal emulator)
# - Editor: nvf (Neovim), vscode (VS Code)
# - Browser: chrome (Chromium-based browser)
# - Communication: discord (with nixcord themes) [Linux only via Nix]
# - Productivity: obsidian (note-taking), yazi (file manager)
# - Version Control: git (with identity configuration)
# - Launcher: fuzzel (application launcher) [Linux/Wayland only]
# =============================================================================
{ pkgs, config, lib, isDarwin ? false, ... }:

let
  # ---------------------------------------------------------------------------
  # CROSS-PLATFORM IMPORTS
  # ---------------------------------------------------------------------------
  # Programs that work on both Linux and macOS
  commonImports = [
    # --- Development Tools ---
    ../programs/git/git.nix        # Git version control with user identity
    ../programs/zed-editor/zed-editor.nix  # Zed editor

    # --- Shell and Terminal ---
    ../programs/zsh/zsh.nix        # Zsh shell with oh-my-zsh and plugins
    ../programs/yazi/yazi.nix      # Terminal file manager
  ];

  # ---------------------------------------------------------------------------
  # LINUX-ONLY IMPORTS
  # ---------------------------------------------------------------------------
  # Programs that only work on Linux (Wayland, X11, or Linux-specific)
  # macOS equivalents are typically installed via Homebrew casks
  linuxImports = [
    ../programs/alacritty/alacritty.nix  # GPU-accelerated terminal (use Homebrew on macOS)
    ../programs/chrome/chrome.nix        # Chromium browser (use Homebrew on macOS)
    ../programs/discord/discord.nix      # Discord with custom themes (use Homebrew on macOS)
    ../programs/fuzzle/fuzzle.nix        # Wayland application launcher
    ../programs/vscode/vscode.nix        # VS Code editor (use Homebrew on macOS)
    ../programs/zellij/zellij.nix        # Terminal workspace manager
  ];
in
{
  # ---------------------------------------------------------------------------
  # PROGRAM MODULE IMPORTS
  # ---------------------------------------------------------------------------
  # Each import loads a complete program configuration
  # Programs can be commented out to disable them
  imports = commonImports ++ (lib.optionals (!isDarwin) linuxImports);

  # ---------------------------------------------------------------------------
  # INLINE PROGRAM CONFIGURATIONS
  # ---------------------------------------------------------------------------
  # Simple programs that don't need dedicated files
  # For complex configs, create a separate file and import above
  programs = {
    # --- Terminal Enhancement ---
    # bat: Syntax-highlighted 'cat' replacement
    # Features: Line numbers, git integration, paging
    # Usage: bat file.txt
    bat.enable = true;

    # --- Environment Management ---
    # direnv: Automatically load environment variables per directory
    # nix-direnv: Nix-specific direnv integration for flakes
    # Use case: Per-project development environments
    # Usage: Create .envrc with "use flake" in project root
    direnv = {
      enable = true;
      nix-direnv.enable = true;  # Cache nix-shell environments
    };

    # --- Fuzzy Finder ---
    # fzf: Interactive fuzzy finder for files, history, etc.
    # Integrates with shell (Ctrl+R, Ctrl+T) and vim
    fzf = {
      enable = true;
      # Use fd instead of find (respects .gitignore, faster)
      defaultCommand = "fd --type file --follow";
      # Compact display (20% of screen height)
      defaultOptions = [ "--height 20%" ];
    };

    # --- System Monitor ---
    # htop: Interactive process viewer
    # Alternative: bottom (btm) installed in packages
    htop = {
      enable = true;
      settings = {
        # Sort by CPU usage by default
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };

    # --- JSON Processor ---
    # jq: Command-line JSON processor
    # Usage: echo '{"key":"value"}' | jq '.key'
    jq.enable = true;
  };
  
  # ---------------------------------------------------------------------------
  # PROGRAM MANAGEMENT NOTES
  # ---------------------------------------------------------------------------
  # To disable a program:
  # - Comment out its import line
  # - OR create a custom profile without that import
  #
  # To add a complex program:
  # - Create home/programs/<name>/<name>.nix
  # - Configure all options in that file
  # - Add import to this file
  #
  # To add a simple program:
  # - Just add it to the programs = { } block above
  # - Use for programs with minimal configuration
  # ---------------------------------------------------------------------------
}
