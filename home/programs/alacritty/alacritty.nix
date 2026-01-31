# =============================================================================
# ALACRITTY TERMINAL CONFIGURATION
# =============================================================================
# GPU-accelerated terminal emulator configuration
#
# ALACRITTY FEATURES:
# - OpenGL rendering for smooth performance
# - Cross-platform (Linux, macOS, Windows)
# - Minimal resource usage
#
# THEME: Claude Dark
# - Warm, earthy colors easy on the eyes
# - Terracotta accents
# - Sage greens and dusty blues
#
# MACOS NOTE:
# - option_as_alt = "Both" enables Alt+key bindings for Zellij
# =============================================================================
{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      # -----------------------------------------------------------------------
      # WINDOW
      # -----------------------------------------------------------------------
      window = {
        # Padding around terminal content
        padding = { x = 8; y = 8; };

        # Window decorations (macOS: Buttonless hides title bar buttons)
        decorations = "Buttonless";

        # Opacity (1.0 = fully opaque)
        opacity = 1.0;

        # Startup mode
        startup_mode = "Windowed";

        # Make Option key behave as Alt (required for Zellij Alt+key bindings)
        option_as_alt = "Both";
      };

      # -----------------------------------------------------------------------
      # FONT
      # -----------------------------------------------------------------------
      font = {
        size = 14.0;

        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };

        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };

        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
      };

      # -----------------------------------------------------------------------
      # SCROLLING
      # -----------------------------------------------------------------------
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # -----------------------------------------------------------------------
      # CURSOR
      # -----------------------------------------------------------------------
      cursor = {
        style = {
          shape = "Block";
          blinking = "Off";
        };
      };

      # -----------------------------------------------------------------------
      # SELECTION
      # -----------------------------------------------------------------------
      selection = {
        save_to_clipboard = true;
      };

      # -----------------------------------------------------------------------
      # TERMINAL
      # -----------------------------------------------------------------------
      terminal = {
        osc52 = "CopyPaste";
      };

      # -----------------------------------------------------------------------
      # COLORS - Claude Dark Theme
      # -----------------------------------------------------------------------
      # Warm, earthy palette - easy on the eyes
      colors = {
        primary = {
          foreground = "#E8E0D4";  # Warm off-white
          background = "#2A2520";  # Warm dark brown
        };

        cursor = {
          cursor = "#D97757";  # Terracotta
          text = "#2A2520";
        };

        selection = {
          background = "#4A423A";  # Muted brown
          text = "#E8E0D4";
        };

        normal = {
          black   = "#1A1815";  # Deep warm black
          red     = "#D97757";  # Terracotta
          green   = "#7BAA8E";  # Sage green
          yellow  = "#D4A44D";  # Warm gold
          blue    = "#6B8B9C";  # Dusty blue
          magenta = "#B68F9A";  # Dusty rose
          cyan    = "#8AABA1";  # Sage seafoam
          white   = "#F5F1E8";  # Cream
        };

        bright = {
          black   = "#3D3529";  # Warm charcoal
          red     = "#E8875F";  # Bright terracotta
          green   = "#8BBAA0";  # Bright sage
          yellow  = "#E4B45D";  # Bright gold
          blue    = "#7B9BAC";  # Bright dusty blue
          magenta = "#C69FAA";  # Bright dusty rose
          cyan    = "#9ABBB1";  # Bright seafoam
          white   = "#FAF8F3";  # Bright cream
        };
      };
    };
  };
}
