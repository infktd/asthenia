````markdown
# home/themes/

This directory contains theme configurations for GTK, Qt, and color schemes.

## Files

### colors.nix
Base16 color schemes used across configurations.

**Usage:**
```nix
let
  colors = import ../../themes/colors.nix;
in
{
  # Use colors in your config
  services.dunst.settings = with colors.scheme.helios; {
    frame_color = "${base00}";
    # ...
  };
}
```

### default.nix
GTK theme and icon theme configurations.

**Configured:**
- GTK icon theme (BeautyLine)
- GTK theme (Juno-ocean)
- Dark theme preference for GTK4

## Adding New Themes

### Add a Color Scheme

Edit `colors.nix`:
```nix
{
  scheme = {
    helios = { ... };
    
    my-scheme = {
      scheme = "My Scheme";
      author = "Your Name";
      base00 = "000000"; # background
      base05 = "ffffff"; # foreground
      # ... more colors
    };
  };
}
```

### Add GTK Theme

Edit `default.nix`:
```nix
gtk = {
  theme = {
    name = "My-Theme";
    package = pkgs.my-theme-package;
  };
};
```

## Popular Themes

- **GTK Themes:** Juno, Materia, Nordic, Dracula
- **Icon Themes:** BeautyLine, Papirus, Numix
- **Color Schemes:** Base16 provides hundreds of schemes

## Notes

- Themes are applied user-level through Home Manager
- GTK themes affect most Linux applications
- Qt theme configuration can be added separately
- Icon themes should match your overall aesthetic

````