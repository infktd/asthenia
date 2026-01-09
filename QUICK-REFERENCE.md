# Quick Reference: New Additions

This document provides a quick reference for all the new components added from the gvolpe/nix-config structure.

## 🎨 Theming System

### Location: `home/themes/`

**colors.nix** - Base16 Helios color scheme
```nix
# Import in your configs:
colors = import ../themes/colors.nix;

# Use colors:
background = colors.base00;
foreground = colors.base05;
```

**default.nix** - GTK themes
- BeautyLine icon theme
- Juno-ocean GTK theme
- Automatically applied when imported

## 🪟 Window Manager (Niri)

### User Config: `home/wm/niri/`

**default.nix** - User environment
- Niri packages and dependencies
- Session variables
- XDG portals
- Imports programs (kitty, etc.)

**config.kdl** - Niri configuration
- Keybindings (Mod+T = terminal, Mod+Q = close)
- Layout settings
- Output configuration

### System Config: `system/wm/niri.nix`

System-level services:
- `programs.niri.enable = true`
- greetd login manager
- PipeWire audio
- Bluetooth
- seatd

### How to Use Niri

**Build Home Config:**
```bash
nix build .#homeConfigurations.niri-default.activationPackage
./result/activate
```

**Enable System Support:**
Add to `system/configuration.nix`:
```nix
imports = [
  ./wm/niri.nix
];
```

**Key Bindings:**
- `Mod+T` - Open terminal (kitty)
- `Mod+Q` - Close window
- `Mod+H/L` - Switch workspaces
- `Mod+Shift+H/L` - Move window to workspace
- `Mod+Return` - Fullscreen

## 📦 Programs Example

### Location: `home/programs/kitty/`

Complete example showing how to structure program configs:
- `kitty.nix` - Configuration file
- `README.md` - Documentation

**Template for new programs:**
```
programs/
└── myapp/
    ├── myapp.nix       # Configuration
    └── README.md       # Documentation
```

## 🔤 Fonts

### Location: `system/fonts/default.nix`

Template for custom font packages:
```nix
{ pkgs }:

{
  # Example:
  # my-custom-font = pkgs.fetchFromGitHub { ... };
}
```

Fonts are imported in `system/configuration.nix`:
```nix
myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
```

## 🎭 Miscellaneous

### Location: `system/misc/`

**groot.txt** - Custom sudo prompt
- ASCII art message
- Security reminder
- Referenced in configuration.nix

## 📐 Schemas

### Location: `lib/schemas.nix`

Flake schema definitions for better documentation:
```nix
{
  version = 1;
  doc = "...";
  inventory = output: { ... };
}
```

Used in `flake.nix` for custom attrsets.

## 📦 New Flake Inputs

### niri-flake
```nix
inputs.niri-flake = {
  url = "github:sodiboo/niri-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Provides:
- Niri package
- Home Manager module
- Overlay for integration

## 🔨 Available Build Profiles

### Standard
- `default` - Basic desktop
- `hidpi` - HiDPI support
- `mutable` - Development mode

### Niri
- `niri-default` - Niri WM basic
- `niri-hidpi` - Niri WM + HiDPI
- `niri-mutable` - Niri WM + dev mode

### Build Commands
```bash
# Standard
nix build .#homeConfigurations.default.activationPackage

# Niri
nix build .#homeConfigurations.niri-default.activationPackage

# HiDPI
nix build .#homeConfigurations.hidpi.activationPackage
nix build .#homeConfigurations.niri-hidpi.activationPackage
```

## 📝 Key Configuration Updates

### flake.nix
- Added niri-flake input
- Integrated schemas

### lib/overlays.nix
- Added niri overlay import

### outputs/hm.nix
- Added three niri profiles

### home/shared/default.nix
- Imports themes

### system/configuration.nix
- Custom fonts integration
- Sudo prompt customization

## 🎯 Philosophy: shared/ vs programs/

### home/shared/
**Purpose:** Base configuration always applied
**Contains:** Essential tools, base packages, foundational configs
**Example:** git, fish, base programs list

### home/programs/
**Purpose:** Optional per-application configs
**Contains:** Dedicated folders with app configs + README
**Example:** kitty/, firefox/, vscode/

**Rule of thumb:**
- If it's essential for every build → `shared/`
- If it's optional and has extensive config → `programs/`

See `home/wm/README.md` for detailed explanation.

## 🚀 Quick Start with Niri

1. **Customize settings:**
   ```bash
   # Edit username
   vim home/shared/default.nix
   
   # Edit system settings
   vim system/configuration.nix
   ```

2. **Generate hardware config:**
   ```bash
   nixos-generate-config --show-hardware-config > system/hardware-configuration.nix
   ```

3. **Build Niri config:**
   ```bash
   nix build .#homeConfigurations.niri-default.activationPackage
   ./result/activate
   ```

4. **Enable system support:**
   Add `./wm/niri.nix` to imports in `system/configuration.nix`

5. **Rebuild system:**
   ```bash
   sudo nixos-rebuild switch --flake .#default
   ```

6. **Log out and select "niri" in login manager**

## 📚 Documentation Files

- `README.md` - Main documentation
- `STRUCTURE.md` - Detailed directory structure
- `GETTING-STARTED.md` - Step-by-step guide
- `CHEATSHEET.md` - Quick commands
- `CHANGELOG.md` - Changes log
- `QUICK-REFERENCE.md` - This file
- `home/wm/README.md` - shared vs programs explanation
- `home/programs/kitty/README.md` - Kitty example

## 🔍 File Locations Quick Reference

```
├── flake.nix                       # Added niri-flake input
├── lib/
│   ├── overlays.nix               # Added niri overlay
│   └── schemas.nix                # NEW: Flake schemas
├── home/
│   ├── shared/default.nix         # Imports themes
│   ├── programs/kitty/            # NEW: Example program
│   ├── themes/                    # NEW: Colors + GTK
│   │   ├── colors.nix            # Base16 Helios
│   │   └── default.nix           # GTK themes
│   └── wm/niri/                   # NEW: Niri user config
│       ├── default.nix           # Environment
│       └── config.kdl            # Keybindings
├── system/
│   ├── configuration.nix          # Fonts + sudo prompt
│   ├── fonts/default.nix         # NEW: Custom fonts
│   ├── misc/groot.txt            # NEW: Sudo prompt
│   └── wm/niri.nix               # NEW: Niri system config
└── outputs/hm.nix                 # Added niri profiles
```

## ✅ Checklist for Customization

- [ ] Update username in `home/shared/default.nix`
- [ ] Update hostname in `system/configuration.nix`
- [ ] Set timezone in `system/configuration.nix`
- [ ] Configure user in `system/configuration.nix`
- [ ] Update git config in `home/shared/programs.nix`
- [ ] Generate `system/hardware-configuration.nix`
- [ ] Choose profile (default or niri variants)
- [ ] Build and test
- [ ] Customize keybindings in `home/wm/niri/config.kdl`
- [ ] Add your own programs following kitty example
