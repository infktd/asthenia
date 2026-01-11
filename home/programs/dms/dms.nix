{ inputs, ... }:

# =============================================================================
# DMS (Dank Material Shell) - Home Manager Configuration
# =============================================================================
# This configures USER-LEVEL DMS settings (appearance, behavior).
# System-level DMS service is managed in system/wm/niri.nix
#
# DUAL-LEVEL CONFIGURATION:
# - System (system/wm/niri.nix):
#   * programs.dms-shell with systemd enabled
#   * Creates and manages dms.service
#   * Binds service to niri session
#
# - User (this file):
#   * programs.dank-material-shell (homeModule)
#   * Theme, colors, appearance settings
#   * User-specific behavior preferences
#
# This split allows:
# - System manages service lifecycle (start/stop/restart)
# - User manages look and feel (no root required)
# =============================================================================

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;

    settings = {
      theme = "dark";
      dynamicTheming = true;
    };
  };
}
