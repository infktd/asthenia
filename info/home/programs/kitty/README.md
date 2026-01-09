````markdown
# home/programs/kitty/

Kitty terminal emulator configuration.

## Files

- `kitty.nix` - Main Kitty configuration

## Configuration

The configuration enables:
- Kitty terminal emulator
- Fish shell integration
- OneDark theme
- JetBrainsMono Nerd Font
- Background opacity
- Disabled audio bell

## Customization

Edit `kitty.nix` to change:
- Font and size
- Theme
- Background opacity
- Keybindings (add to settings)
- Window padding

## Usage

This module is imported in your window manager or shared config:

```nix
imports = [
  ../../programs/kitty/kitty.nix
];
```

Or in `home/shared/programs.nix`:

```nix
{
  imports = [
    ../programs/kitty/kitty.nix
  ];
}
```

## See Also

- [Kitty Documentation](https://sw.kovidgoyal.net/kitty/)
- [Kitty Themes](https://github.com/dexpota/kitty-themes)

````