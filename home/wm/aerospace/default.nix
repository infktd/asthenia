# =============================================================================
# AEROSPACE WINDOW MANAGER CONFIGURATION
# =============================================================================
# User-level configuration for Aerospace tiling window manager on macOS
#
# AEROSPACE OVERVIEW:
# - Tiling window manager for macOS (i3-like)
# - Keyboard-driven workflow
# - Virtual workspaces
# - Configuration via TOML file
#
# INSTALLATION:
# Aerospace is installed via Homebrew (see system/machine/esoteric/homebrew.nix)
# This module configures the user-level settings and keybindings
#
# CONFIGURATION:
# - Main config: ~/.config/aerospace/aerospace.toml
# - Keybindings and workspace rules defined in config
#
# USAGE:
# - Switch profile: home-manager switch --flake .#aerospace
# - Grant accessibility permissions in System Settings > Privacy > Accessibility
# =============================================================================
{ config, lib, pkgs, inputs, ... }:

let
  # ---------------------------------------------------------------------------
  # FONTS
  # ---------------------------------------------------------------------------
  nerdFonts = with (pkgs.nerd-fonts); [
    fira-code
    iosevka
    jetbrains-mono
  ];

  fontPkgs = with pkgs; [
    font-awesome
    material-design-icons
  ] ++ nerdFonts;

  # ---------------------------------------------------------------------------
  # PACKAGES
  # ---------------------------------------------------------------------------
  # macOS-compatible packages for desktop environment
  # Note: GUI apps like Alacritty are installed via Homebrew casks
  packages = with pkgs; [
    # --- Clipboard ---
    # macOS has pbcopy/pbpaste built-in

    # --- Fonts ---
  ] ++ fontPkgs;

in
{
  # === FONTS ===
  fonts.fontconfig.enable = true;

  # === HOME ===
  home.packages = packages;
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${lib.exe pkgs.zsh}";
  };
  home.stateVersion = "24.11";

  # === IMPORTS ===
  imports = [
    ../../shared
  ];

  # === XDG ===
  # Aerospace configuration file
  xdg.configFile."aerospace/aerospace.toml".source = ./config/aerospace.toml;
}
