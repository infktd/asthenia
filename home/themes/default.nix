# =============================================================================
# GTK THEME CONFIGURATION
# =============================================================================
# User-level GTK theming for consistent look across GTK applications
#
# PLATFORM: Linux only (GTK is not used on macOS)
# macOS uses native AppKit theming controlled via System Settings
#
# THEMES USED:
# - GTK Theme: Juno-ocean (dark theme)
# - Icon Theme: BeautyLine (modern icon set)
#
# APPLIES TO:
# - All GTK3 and GTK4 applications
# - File managers (Nemo, Nautilus)
# - System settings dialogs
# - Many Electron apps that respect GTK
#
# DARK MODE:
# - Enforced via gtk-application-prefer-dark-theme
# - Custom CSS import for GTK4 dark variant
#
# TESTING THEMES:
# - Preview: gtk3-demo or gtk4-demo
# - Browse themes: https://www.gnome-look.org/
# =============================================================================
{ pkgs, lib, isDarwin ? false, ... }: {
  gtk = lib.mkIf (!isDarwin) rec {
    # Enable GTK theme management via Home Manager
    # Only on Linux - macOS doesn't use GTK
    enable = true;
    
    # ---------------------------------------------------------------------------
    # ICON THEME
    # ---------------------------------------------------------------------------
    # BeautyLine: Colorful and modern icon theme
    # Provides icons for applications, file types, and system elements
    iconTheme = {
      name = "BeautyLine";
      package = pkgs.beauty-line-icon-theme;
    };
    
    # ---------------------------------------------------------------------------
    # GTK THEME
    # ---------------------------------------------------------------------------
    # Juno: Modern, clean theme with ocean color variant
    # Supports both GTK3 and GTK4
    theme = {
      name = "Juno-ocean";
      package = pkgs.juno-theme;
    };
    
    # ---------------------------------------------------------------------------
    # GTK4 CONFIGURATION
    # ---------------------------------------------------------------------------
    # GTK4-specific settings (latest GTK version)
    gtk4 = {
      # Force dark theme preference
      # Applications should use dark variant when available
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      
      # Import dark theme CSS
      # Some themes don't apply dark variant by default
      # This explicitly loads the dark CSS file
      extraCss = ''
        @import url("file://${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk-dark.css");
      '';
    };
    
    # ---------------------------------------------------------------------------
    # ADDITIONAL THEMING OPTIONS
    # ---------------------------------------------------------------------------
    # Uncomment to customize further:
    #
    # gtk3.extraConfig:
    #   gtk-application-prefer-dark-theme = true
    #   gtk-cursor-theme-name = "Adwaita"
    #   gtk-cursor-theme-size = 24
    #
    # gtk3.extraCss:
    #   Custom CSS rules for GTK3 applications
    #
    # Font configuration:
    #   font.name = "Sans";
    #   font.size = 11;
    # ---------------------------------------------------------------------------
  };
}
