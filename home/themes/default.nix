{ pkgs, ... }: {
  gtk = rec {
    enable = true;
    iconTheme = {
      name = "BeautyLine";
      package = pkgs.beauty-line-icon-theme;
    };
    theme = {
      name = "Juno-ocean";
      package = pkgs.juno-theme;
    };
    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      # The dark files are not copied by default, as not all themes have separate files
      extraCss = ''
        @import url("file://${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk-dark.css");
      '';
    };
  };
}
