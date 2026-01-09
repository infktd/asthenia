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
- Font packages (Nerd Fonts, Font Awesome, Material Design Icons)
- Audio utilities (pavucontrol, playerctl, etc.)
- System utilities (brightnessctl, grim, wl-clipboard, etc.)
- Polkit authentication agent
- Imports all programs:
  - Firefox, Discord (nixcord), Obsidian, VS Code
  - Kitty terminal, Yazi file manager
  - nvf (Neovim), Fuzzle launcher
  - DankMaterialShell (quickshell)

**config.kdl** - Niri configuration
- Main configuration file
- Imports modular configs from `config/` directory

**config/** - Modular configuration files:
- `binds.kdl` - Keybindings
- `edp.kdl` - Display settings
- `input.kdl` - Input device configuration
- `layers.kdl` - Layer shell configuration
- `layout.kdl` - Window layout settings
- `misc.kdl` - Miscellaneous settings
- `workspaces.kdl` - Workspace configuration

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
nix build .#homeConfigurations.niri.activationPackage
./result/activate
```

**Enable System Support:**
Add to machine's `default.nix` (e.g., `system/machine/arasaka/default.nix`):
```nix
imports = [
  ../../wm/niri.nix
  # ... other imports
];
```

**Key Bindings:**
See [home/wm/niri/config/binds.kdl](home/wm/niri/config/binds.kdl) for full list.

## 📦 Programs Configuration

### Location: `home/programs/`

**Available Programs:**
- `discord/` - Discord (via nixcord)
- `dms/` - DankMaterialShell (quickshell)
- `firefox/` - Firefox browser
- `fuzzle/` - Fuzzle launcher
- `git/` - Git configuration
- `kitty/` - Kitty terminal emulator
- `nvf/` - Neovim (nvf framework) with multiple modules:
  - `keymaps.nix` - Key mappings
  - `languages.nix` - Language support
  - `mini.nix` - mini.nvim plugin configuration
  - `nvf.nix` - Main nvf configuration
  - `options.nix` - Editor options
  - `picker.nix` - File picker configuration
  - `snacks.nix` - Snacks.nvim plugin
  - `utils.nix` - Utility functions
- `obsidian/` - Obsidian notes
- `vscode/` - VS Code editor
- `yazi/` - Yazi file manager

**Template for new programs:**
```
programs/
└── myapp/
    └── myapp.nix       # Configuration
```

**Importing programs:**
- For niri: Import in `home/wm/niri/default.nix`
- For base: Import in `home/shared/programs.nix`



## 📦 Flake Inputs

### niri-flake
```nix
inputs.niri-flake = {
  url = "github:sodiboo/niri-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### nvf (Neovim)
```nix
inputs.nvf = {
  url = "github:notashelf/nvf";
};
```

### nixcord (Discord)
```nix
inputs.nixcord = {
  url = "github:kaylorben/nixcord";
};
```

### dms (DankMaterialShell)
```nix
inputs.dms = {
  url = "github:AvengeMedia/DankMaterialShell";
};
```

## 🔨 Available Build Profiles

### Home Manager
- `default` - Minimal base configuration (shared only)
- `niri` - Full Niri WM setup with all programs

### NixOS
- `arasaka` - Current machine configuration

### Build Commands
```bash
# Base configuration
nix build .#homeConfigurations.default.activationPackage

# Niri with all programs
nix build .#homeConfigurations.niri.activationPackage

# NixOS system
sudo nixos-rebuild switch --flake .#arasaka
```

## 📝 Key Files

### flake.nix
- Defines all inputs (nixpkgs, home-manager, niri, nvf, nixcord, dms)
- Uses builder pattern from lib/overlays.nix
- Exports homeConfigurations and nixosConfigurations
- Includes flake schemas

### lib/overlays.nix
- Implements builder pattern (mkHome, mkNixos)
- Extends lib with custom functions
- Integrates niri overlay

### lib/default.nix
- `exe` - Extract executable path from package
- `removeNewline` - String manipulation
- `secretManager.readSecret` - Secret handling

### outputs/hm.nix
- Defines two profiles: `default` and `niri`
- Uses mkHome builder

### outputs/os.nix
- Defines system configurations
- Current hosts: `["arasaka"]`
- Uses mkNixos builder

### home/shared/default.nix
- Base configuration for all profiles
- User settings and base packages
- Imports themes

### home/wm/niri/default.nix
- Niri environment setup
- Imports shared + all programs
- Font and audio packages

### system/configuration.nix
- Global system settings
- Custom fonts integration
- Sudo prompt customization (groot.txt)
- Nix settings and garbage collection

### system/wm/niri.nix
- System-level niri integration
- Greetd login manager
- PipeWire audio
- Bluetooth and seatd

## 🎯 Configuration Philosophy

### home/shared/
**Purpose:** Base configuration always applied
**Contains:** Essential tools, base packages, foundational configs
**Example:** bat, fzf, htop, git settings
**Imported by:** Both `default` and `niri` configurations

### home/programs/
**Purpose:** Per-application dedicated configurations
**Contains:** Each program in its own directory with .nix file
**Example:** `firefox/firefox.nix`, `kitty/kitty.nix`
**Imported by:** Typically `home/wm/niri/default.nix` for full setup

### Builder Pattern
**Purpose:** Consistent, reusable configuration building
**Location:** `lib/overlays.nix`
**Exposed as:** `pkgs.builders.mkHome` and `pkgs.builders.mkNixos`
**Benefits:** Centralized build logic, easy to extend

### Configuration Layering
```
default config:  shared/
niri config:     shared/ + programs/ + wm/niri/
```

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

- [ ] Update username in [home/shared/default.nix](home/shared/default.nix)
- [ ] Update hostname in machine config
- [ ] Update user in [system/configuration.nix](system/configuration.nix)
- [ ] Set timezone in [system/configuration.nix](system/configuration.nix)
- [ ] Generate hardware-configuration.nix
- [ ] Choose profile (`default` or `niri`)
- [ ] Build and test
- [ ] Customize keybindings if using niri
- [ ] Add/remove programs as needed
