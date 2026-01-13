# =============================================================================
# ALACRITTY TERMINAL CONFIGURATION
# =============================================================================
# GPU-accelerated terminal emulator configuration
#
# ALACRITTY FEATURES:
# - OpenGL rendering for smooth performance
# - Cross-platform (Linux, macOS, Windows)
# - Minimal configuration in TOML/YAML
# - Vi mode for keyboard navigation
#
# THEME:
# - Oxocarbon: IBM Carbon-inspired dark theme
# - Good contrast and readability
# - Separate theme file for easy switching
#
# CONFIGURATION STRUCTURE:
# - Theme: Separate TOML file (~/.config/alacritty/theme.toml)
# - Settings: Managed by Home Manager
# - Import theme via general.import
# =============================================================================
{ config, pkgs, lib, ... }:

let
  # ---------------------------------------------------------------------------
  # OXOCARBON THEME
  # ---------------------------------------------------------------------------
  # IBM Carbon Design-inspired color scheme
  # Features muted colors for reduced eye strain
  #
  # THEME STRUCTURE:
  # - primary: Background and foreground colors
  # - normal: Standard ANSI colors (black, red, green, etc.)
  # - bright: Bright/bold variants of ANSI colors
  #
  # TO CHANGE THEME:
  # 1. Create new theme TOML file
  # 2. Update oxocarbonToml variable
  # 3. Run: home-manager switch
  # ---------------------------------------------------------------------------
  oxocarbonToml = pkgs.writeText "theme.toml" ''
[colors.primary]
background = "#161616"  # Very dark gray (not pure black)
foreground = "#f2f4f8"  # Light gray for text

[colors.normal]
black   = "#262626"  # Terminal black
red     = "#ee5396"  # Pink-red
green   = "#42be65"  # Mint green
yellow  = "#ffe97b"  # Soft yellow
blue    = "#33b1ff"  # Cyan-blue
magenta = "#be95ff"  # Purple
cyan    = "#3ddbd9"  # Turquoise
white   = "#dde1e6"  # Light gray

[colors.bright]
black   = "#393939"  # Lighter black
red     = "#ff7eb6"  # Bright pink-red
green   = "#57fa99"  # Bright green
yellow  = "#fddc6c"  # Bright yellow
blue    = "#78a9ff"  # Bright blue
magenta = "#d4bbff"  # Bright purple
cyan    = "#08bdba"  # Bright cyan
white   = "#ffffff"  # Pure white
'';
in
{
  # ---------------------------------------------------------------------------
  # THEME FILE INSTALLATION
  # ---------------------------------------------------------------------------
  # Install theme to ~/.config/alacritty/theme.toml
  # Alacritty will import this file on startup
  xdg.configFile."alacritty/theme.toml".source = oxocarbonToml;
  
  # ---------------------------------------------------------------------------
  # ALACRITTY CONFIGURATION
  # ---------------------------------------------------------------------------
  programs.alacritty = {
    # Enable Alacritty terminal emulator
    enable = true;
    
    # Settings map to alacritty.toml configuration
    settings = {
      # -----------------------------------------------------------------------
      # IMPORTS
      # -----------------------------------------------------------------------
      # Import external theme file
      # Allows easy theme switching without changing main config
      general.import = [ "~/.config/alacritty/theme.toml" ];
      
      # -----------------------------------------------------------------------
      # FONT CONFIGURATION
      # -----------------------------------------------------------------------
      font = {
        # Use system monospace font
        # Typically resolves to JetBrains Mono or Iosevka (from Nerd Fonts)
        normal.family = "JetBrains Mono Nerd Font";
        
        # Font size in points
        # Adjust based on monitor DPI and preference
        size = 12.0;
        
        # Additional font options:
        # bold.family = "monospace";
        # italic.family = "monospace";
      };
      
      # -----------------------------------------------------------------------
      # WINDOW SETTINGS
      # -----------------------------------------------------------------------
      window = {
        # Window opacity (0.0 = transparent, 1.0 = opaque)
        # Requires compositor support (works with Niri/Wayland)
        opacity = 0.75;
        
        # Padding around terminal text
        # Provides breathing room at window edges
        padding = { x = 0; y = 0; };
        
        # Additional window options:
        # decorations = "full";  # "full", "none", or "transparent"
        # startup_mode = "Windowed";  # "Windowed", "Maximized", "Fullscreen"
        # dynamic_title = true;  # Update title based on terminal content
      };
      
      # -----------------------------------------------------------------------
      # ADDITIONAL CONFIGURATION OPTIONS
      # -----------------------------------------------------------------------
      # Scrollback buffer (lines to keep in memory):
      # scrolling.history = 10000;
      #
      # Cursor style:
      # cursor.style = { shape = "Block"; blinking = "Off"; };
      #
      # Mouse bindings:
      # mouse.hide_when_typing = true;
      #
      # Key bindings:
      # key_bindings = [
      #   { key = "V"; mods = "Control|Shift"; action = "Paste"; }
      #   { key = "C"; mods = "Control|Shift"; action = "Copy"; }
      # ];
      # -----------------------------------------------------------------------
    };
  };
}
