````markdown
# home/wm/

This directory contains window manager configurations at the user level (Home Manager).

## Purpose

User-specific window manager environments including packages, settings, and integrations.

## Structure

### niri/
Niri window manager configuration (scrollable-tiling Wayland compositor).

**Components:**
- `default.nix` - Main configuration with packages and settings
- `config.kdl` - Niri configuration file (keybindings, layout, etc.)

## Usage

### Building a Niri Configuration

Configurations are imported through the outputs system:

**In `outputs/hm.nix`:**
```nix
mkNiriHome = { hidpi, mut ? false }: mkHome {
  inherit hidpi mut;
  mods = [ ../home/wm/niri ];
};
```

**Build command:**
```bash
nix build .#homeConfigurations.niri-default.activationPackage
./result/activate
```

## Difference: programs/ vs shared/

### **programs/** Directory
Per-application configurations in their own modules.

**When to use:**
- Specific program configuration (kitty, neovim, firefox)
- Self-contained configs that can be toggled on/off
- Program-specific options and settings

**Example:**
```
programs/
├── kitty/
│   └── kitty.nix  # Kitty terminal config
├── firefox/
│   └── default.nix  # Firefox browser config
```

Each program is independent and can be imported selectively.

### **shared/** Directory
Base configuration applied to all profiles.

**When to use:**
- Common packages used everywhere
- Base program settings (git, htop, direnv)
- Settings that should be consistent across all configs

**Example:**
```
shared/
├── default.nix    # Common packages & settings
├── programs.nix   # Base program configs
└── services.nix   # Base service configs
```

Applied to every home configuration automatically.

### **Quick Decision Guide**

Use `programs/`:
- ✅ Application-specific configuration
- ✅ Can be enabled/disabled per profile
- ✅ Has its own settings and files
- ✅ Example: Terminal emulators, editors, browsers

Use `shared/`:
- ✅ Always needed packages
- ✅ Universal settings (git config, shell)
- ✅ Core utilities
- ✅ Example: wget, curl, git, basic shell

## Adding Window Managers

Create a new directory for each window manager:

```
wm/
├── niri/
│   ├── default.nix
│   └── config.kdl
├── hyprland/
│   ├── default.nix
│   └── hyprland.conf
└── sway/
    ├── default.nix
    └── config
```

## Window Manager Features

### Common Components
- **Font packages** - Nerd fonts, icons
- **Audio packages** - PulseAudio/PipeWire tools
- **Wayland tools** - wl-clipboard, portal support
- **Session variables** - WAYLAND_DISPLAY, etc.

### Integration
- Import from `../../shared` for base config
- Import specific programs from `../../programs/`
- Import services from `../../services/`

## Notes

- Window manager configs include system dependencies
- Match system WM config in `system/wm/`
- Only one WM should be active per home configuration
- Test configs in a VM before deploying

````