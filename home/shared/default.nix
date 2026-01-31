# =============================================================================
# SHARED USER CONFIGURATION
# =============================================================================
# Base user configuration included in ALL Home Manager profiles
# This is the foundation that other profiles build upon
#
# ARCHITECTURE:
# - This module: Core user settings, base packages, universal programs
# - Profile modules (niri, aerospace, etc.): Add WM-specific packages and config
#
# INCLUDED IN:
# - home/wm/niri (Linux desktop profile)
# - home/wm/aerospace (macOS desktop profile)
# - Future profiles (kde, hyprland, minimal, etc.)
#
# CROSS-PLATFORM SUPPORT:
# - Detects darwin vs Linux via isDarwin parameter
# - Adjusts homeDirectory path automatically (/Users vs /home)
# - Filters out Linux-only packages on darwin
#
# WHAT BELONGS HERE:
# - Programs used across all profiles (git, shell, editor)
# - Universal development tools
# - Core utilities (file management, system monitoring)
# - Scripts available in all environments
#
# WHAT DOESN'T BELONG HERE:
# - Window manager specific packages (belong in wm/<name>/)
# - GUI apps only needed in desktop (belong in wm/<name>/)
# - Machine-specific tools (add per-profile)
# - Linux-only packages (use conditional or place in wm/niri)
# =============================================================================
{
  pkgs,
  lib,
  isDarwin ? false,
  ...
}: let
  # ---------------------------------------------------------------------------
  # USER IDENTITY
  # ---------------------------------------------------------------------------
  # Username and home directory configuration
  # Automatically adjusts for macOS (/Users) vs Linux (/home)
  # Different usernames per platform: jayne (macOS), infktd (Linux)
  username = if isDarwin then "jayne" else "infktd";
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  configHome = "${homeDirectory}/.config";

  # ---------------------------------------------------------------------------
  # CUSTOM SCRIPTS
  # ---------------------------------------------------------------------------
  # Import user scripts from home/scripts/
  # Provides: asthenia (rebuild helper)
  scripts = pkgs.callPackage ../scripts {};

  # ---------------------------------------------------------------------------
  # BASE USER PACKAGES
  # ---------------------------------------------------------------------------
  # Core utilities available in all profiles
  # These tools are useful in both CLI and GUI environments
  #
  # CROSS-PLATFORM:
  # - Common packages work on both Linux and macOS
  # - Linux-only packages are filtered out on Darwin
  # - macOS GUI apps typically installed via Homebrew casks
  # ---------------------------------------------------------------------------

  # Packages available on all platforms
  commonPackages = with pkgs; [
    # --- Applications ---
    obsidian # Note-taking app
    signal-desktop # Secure messaging

    # --- Development Tools ---
    claude-code # Claude AI code assistant
    git # Version control
    github-copilot-cli # GitHub Copilot CLI tool
    go # Go programming language
    nodejs # Node.js runtime
    opencode # Opensource code editor
    python3 # Python interpreter

    # --- File and Directory Navigation ---
    eza # Modern ls replacement with colors and icons
    fd # Fast find replacement with intuitive syntax
    tree # Directory tree viewer

    # --- File Management ---
    unzip # Extract zip archives
    zip # Create zip archives

    # --- System Monitoring and Information ---
    bottom # Modern system monitor (btm) - alternative to htop
    dust # Disk usage analyzer - visual, fast alternative to du

    # --- Text Search and Processing ---
    ripgrep # Fast grep alternative (rg) - respects .gitignore
  ];

  # Packages only available on Linux
  linuxPackages = with pkgs; [
    # --- Applications (Linux-specific or better on Linux) ---
    bolt-launcher # Launcher application
    vlc # Media player
    yubioath-flutter # Yubikey authenticator

    # --- System Utilities (Linux-specific) ---
    vulkan-tools # Vulkan utilities (vulkaninfo, etc.)
    xdg-utils # Utilities for managing XDG directories and MIME types
    xorg.xhost # X11 access control (needed for some apps)
  ];

  packages =
    commonPackages
    ++ (lib.optionals (!isDarwin) linuxPackages)
    ++ (lib.attrValues (lib.filterAttrs (n: v: !lib.isFunction v) scripts));
in {
  # ---------------------------------------------------------------------------
  # HOME MANAGER
  # ---------------------------------------------------------------------------
  # Enable Home Manager to manage itself
  # Required for home-manager switch commands to work
  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # MODULE IMPORTS
  # ---------------------------------------------------------------------------
  # Import modular configuration files
  imports = [
    ../themes # GTK themes, icons, fonts
    ./programs.nix # Program-specific configurations
    ./services.nix # User-level services (gpg-agent, etc.)
  ];

  # ---------------------------------------------------------------------------
  # XDG BASE DIRECTORIES
  # ---------------------------------------------------------------------------
  # Standard Linux directory structure for config/data/cache
  # Ensures apps put files in the right places
  xdg = {
    inherit configHome; # ~/.config
    enable = true; # Enable XDG directory management
    # Also provides: ~/.local/share, ~/.cache, etc.
  };

  # ---------------------------------------------------------------------------
  # HOME CONFIGURATION
  # ---------------------------------------------------------------------------
  home = {
    inherit username homeDirectory packages;

    # State version - NEVER CHANGE after initial setup
    # This ensures Home Manager knows which options are compatible
    # Changing this after initial setup can break your configuration
    stateVersion = "24.11";

    # Session environment variables
    # Available in all shells and graphical sessions
    sessionVariables = {
      # Default text editor for CLI tools
      EDITOR = "nvim";
      # Note: Additional session vars for Wayland/NVIDIA in home/wm/niri
    };
  };

  # ---------------------------------------------------------------------------
  # SYSTEMD USER SERVICES (Linux only)
  # ---------------------------------------------------------------------------
  # Restart systemd services on Home Manager switch
  # "sd-switch" mode: Restart changed services, start new ones, stop removed ones
  # Alternatives:
  # - "legacy": Just reload systemd daemon
  # - "suggest": Show commands to run manually
  #
  # NOTE: This is Linux-only; macOS uses launchd instead
  systemd.user.startServices = lib.mkIf (!isDarwin) "sd-switch";
}
