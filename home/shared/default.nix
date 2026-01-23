# =============================================================================
# SHARED USER CONFIGURATION
# =============================================================================
# Base user configuration included in ALL Home Manager profiles
# This is the foundation that other profiles build upon
#
# ARCHITECTURE:
# - This module: Core user settings, base packages, universal programs
# - Profile modules (niri, etc.): Add WM-specific packages and config
#
# INCLUDED IN:
# - home/wm/niri (desktop profile)
# - Future profiles (kde, hyprland, minimal, etc.)
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
# =============================================================================
{
  pkgs,
  lib,
  ...
}: let
  # ---------------------------------------------------------------------------
  # USER IDENTITY
  # ---------------------------------------------------------------------------
  # Username and home directory configuration
  # Change these to match your system user
  username = "infktd";
  homeDirectory = "/home/${username}";
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
  packages = with pkgs;
    [
      # --- System Monitoring and Information ---
      bottom # Modern system monitor (btm) - alternative to htop
      dust # Disk usage analyzer - visual, fast alternative to du

      # --- File and Directory Navigation ---
      eza # Modern ls replacement with colors and icons
      fd # Fast find replacement with intuitive syntax
      tree # Directory tree viewer

      # --- Text Search and Processing ---
      ripgrep # Fast grep alternative (rg) - respects .gitignore

      # --- Applications ---
      bolt-launcher # Launcher application
      signal-desktop # Secure messaging
      vlc # Media player
      yubioath-flutter # Yubikey authenticator
      obsidian # Note-taking app

      # --- System Utilities ---
      xorg.xhost # X11 access control (needed for some apps)

      # --- File Management ---
      unzip # Extract zip archives
      zip # Create zip archives

      # --- Development Tools ---
      git # Version control
      github-copilot-cli # GitHub Copilot CLI tool
      opencode # Opensource code editor

      # --- Programming Languages ---
      python3 # Python interpreter
      nodejs # Node.js runtime
    ]
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
  # SYSTEMD USER SERVICES
  # ---------------------------------------------------------------------------
  # Restart systemd services on Home Manager switch
  # "sd-switch" mode: Restart changed services, start new ones, stop removed ones
  # Alternatives:
  # - "legacy": Just reload systemd daemon
  # - "suggest": Show commands to run manually
  systemd.user.startServices = "sd-switch";
}
