# Project Structure Overview

This document provides a visual guide to understanding the structure of this NixOS configuration.

## Directory Tree

```
.
├── flake.nix                    # Entry point - defines inputs and outputs
│
├── lib/                         # Shared library code
│   ├── default.nix             # Helper functions (exe, secretManager, removeNewline)
│   ├── overlays.nix            # Builder pattern (mkHome, mkNixos) and overlays
│   └── schemas.nix             # Flake schema for custom outputs
│
├── home/                        # Home Manager configuration (user environment)
│   ├── programs/               # Per-application configurations
│   │   ├── discord/            # Discord (nixcord)
│   │   ├── dms/                # DankMaterialShell (quickshell)
│   │   ├── firefox/            # Firefox browser
│   │   ├── fuzzle/             # Fuzzle launcher
│   │   ├── git/                # Git configuration
│   │   ├── kitty/              # Kitty terminal
│   │   ├── nvf/                # Neovim (nvf framework)
│   │   ├── obsidian/           # Obsidian notes
│   │   ├── vscode/             # VS Code editor
│   │   └── yazi/               # Yazi file manager
│   │
│   ├── scripts/                # Helper scripts
│   │   ├── default.nix
│   │   └── example-script.nix
│   │
│   ├── secrets/                # Private data (gitignored)
│   │   └── README.md
│   │
│   ├── shared/                 # Base configuration for all profiles
│   │   ├── default.nix         # Main config with user settings and packages
│   │   ├── programs.nix        # Shared program settings (bat, fzf, htop, etc.)
│   │   └── services.nix        # Shared service settings
│   │
│   ├── themes/                 # Theming configuration
│   │   ├── colors.nix          # Base16 Helios color scheme
│   │   └── default.nix         # GTK themes
│   │
│   └── wm/                     # Window manager configurations
│       └── niri/               # Niri window manager
│           ├── default.nix     # Niri environment setup + program imports
│           ├── config.kdl      # Main niri config
│           └── config/         # Modular config files
│               ├── binds.kdl
│               ├── edp.kdl
│               ├── input.kdl
│               ├── layers.kdl
│               ├── layout.kdl
│               ├── misc.kdl
│               └── workspaces.kdl
│
├── system/                      # NixOS system configuration
│   ├── configuration.nix       # Global system configuration
│   │
│   ├── fonts/                  # Custom font packages
│   │   └── default.nix
│   │
│   ├── machine/                # Per-machine configurations
│   │   └── arasaka/
│   │       ├── default.nix     # Machine-specific settings
│   │       └── hardware-configuration.nix
│   │
│   ├── misc/                   # Miscellaneous files
│   │   └── groot.txt           # Custom sudo prompt
│   │
│   └── wm/                     # System-level window manager config
│       └── niri.nix            # Niri system integration
│
├── outputs/                     # Build configuration outputs
│   ├── hm.nix                  # Home Manager build definitions
│   └── os.nix                  # NixOS build definitions
│
├── info/                        # Documentation
│   └── README files for various components
│
├── README.md                    # Main documentation
├── GETTING-STARTED.md          # Step-by-step setup guide
├── STRUCTURE.md                # This file
├── QUICK-REFERENCE.md          # Quick reference guide
├── CHEATSHEET.md               # Command cheat sheet
├── CHANGELOG.md                # Change history
└── .gitignore

```

## Data Flow

```
┌──────────────────────────────────────────────────────────┐
│                        flake.nix                         │
│  • Defines inputs (nixpkgs, home-manager, etc.)         │
│  • Imports lib/overlays.nix                             │
│  • Exports homeConfigurations and nixosConfigurations   │
└────────────────┬────────────────────────┬────────────────┘
                 │                        │
        ┌────────▼────────┐      ┌───────▼────────┐
        │  outputs/hm.nix │      │ outputs/os.nix │
        │                 │      │                │
        │ Builds Home     │      │ Builds NixOS   │
        │ Manager configs │      │ system configs │
        └────────┬────────┘      └───────┬────────┘
                 │                        │
        ┌────────▼────────┐      ┌───────▼──────────────┐
        │   home/shared/  │      │  system/machine/     │
        │                 │      │                      │
        │ • default.nix   │      │  • default/          │
        │ • programs.nix  │      │    - default.nix     │
        │ • services.nix  │      │    - hardware-*.nix  │
        └────────┬────────┘      └───────┬──────────────┘
                 │                        │
        ┌────────▼────────┐      ┌───────▼────────────┐
        │   home/modules/ │      │ system/            │
        │   home/programs/│      │ configuration.nix  │
        │   home/services/│      │ modules/           │
        └─────────────────┘      └────────────────────┘
```

## Configuration Layers

### Layer 1: Flake (flake.nix)
- Entry point for the entire configuration
- Defines external dependencies (inputs)
- Exports build targets (outputs)

### Layer 2: Library (lib/)
- Shared code used by all configurations
- Helper functions and utilities
- Package overlays

### Layer 3: Outputs (outputs/)
- Bridges flake.nix with actual configurations
- Defines how to build each configuration type
- Maps names to configuration modules

### Layer 4: Configuration (home/, system/)
- Actual configuration content
- Split between user (home) and system (system)
- Organized by concern (programs, services, modules)

## Configuration Types

### Home Manager (User Environment)
```
Configuration  →  Builder Pattern  →  Module Selection  →  User Environment
   (default)       pkgs.builders        home/shared/
   (niri)           .mkHome()           + home/wm/niri/
                                        + all programs/
```

**Build:**
```bash
nix build .#homeConfigurations.default.activationPackage
./result/activate

# or for niri
nix build .#homeConfigurations.niri.activationPackage
./result/activate
```

### NixOS System
```
Machine Name  →  Builder Pattern  →  System Config  →  System Build
  (arasaka)       pkgs.builders      system/machine/     NixOS System
                   .mkNixos()         + configuration.nix
                                      + wm/niri.nix (optional)
```

**Build:**
```bash
sudo nixos-rebuild switch --flake .#arasaka
```

## Customization Points

### For Users (Home Manager)
1. **Base packages**: Edit [home/shared/default.nix](home/shared/default.nix)
2. **Program configs**: Add to `home/programs/<name>/<name>.nix`
3. **User services**: Edit [home/shared/services.nix](home/shared/services.nix)
4. **Niri programs**: Import in [home/wm/niri/default.nix](home/wm/niri/default.nix)

### For System (NixOS)
1. **Global settings**: Edit [system/configuration.nix](system/configuration.nix)
2. **Machine-specific**: Edit [system/machine/arasaka/default.nix](system/machine/arasaka/default.nix)
3. **Hardware config**: [system/machine/arasaka/hardware-configuration.nix](system/machine/arasaka/hardware-configuration.nix)
4. **Window manager**: Import [system/wm/niri.nix](system/wm/niri.nix) in machine config

### Builder Pattern (Advanced)
1. **Custom builders**: [lib/overlays.nix](lib/overlays.nix)
2. **Helper functions**: [lib/default.nix](lib/default.nix)
3. **Output definitions**: [outputs/hm.nix](outputs/hm.nix), [outputs/os.nix](outputs/os.nix)

## Module Import Chain

### Home Manager

**Default Configuration:**
```
flake.nix
  └→ pkgs.builders.mkHome (from lib/overlays.nix)
      └→ outputs/hm.nix
          └→ home/shared/default.nix
              ├→ home/themes/
              ├→ home/shared/programs.nix (bat, fzf, htop, etc.)
              └→ home/shared/services.nix
```

**Niri Configuration:**
```
flake.nix
  └→ pkgs.builders.mkHome (from lib/overlays.nix)
      └→ outputs/hm.nix
          └→ home/wm/niri/default.nix
              ├→ home/shared/ (base configuration)
              ├→ home/programs/firefox/
              ├→ home/programs/discord/
              ├→ home/programs/obsidian/
              ├→ home/programs/vscode/
              ├→ home/programs/kitty/
              ├→ home/programs/nvf/
              ├→ home/programs/yazi/
              ├→ home/programs/fuzzle/
              └→ home/programs/dms/
```

### NixOS
```
flake.nix
  └→ pkgs.builders.mkNixos (from lib/overlays.nix)
      └→ outputs/os.nix
          └→ system/machine/arasaka/default.nix
              ├→ hardware-configuration.nix
              ├→ system/configuration.nix
              │   ├→ system/fonts/
              │   └→ system/misc/groot.txt
              └→ system/wm/niri.nix (if using niri)
```

## Adding New Components

### New Program (User)
1. Create: `home/programs/myapp/myapp.nix`
2. Add configuration in the file
3. Import in: `home/wm/niri/default.nix` (for niri) or `home/shared/programs.nix` (for all)
4. Rebuild: Home Manager configuration

### New Service (User)
1. Create or edit: `home/shared/services.nix`
2. Add service configuration
3. Rebuild: Home Manager configuration

### New Machine (System)
1. Create: `system/machine/<hostname>/`
2. Add: `default.nix` and `hardware-configuration.nix`
3. Add hostname to: `outputs/os.nix` hosts list
4. Build: `sudo nixos-rebuild switch --flake .#<hostname>`

### New Builder Option (Advanced)
1. Edit: `lib/overlays.nix`
2. Modify `mkHome` or `mkNixos` functions
3. Update: `outputs/hm.nix` or `outputs/os.nix` to use new options

## Customization Points

### For Users (Home Manager)
1. **Base packages**: Edit [home/shared/default.nix](home/shared/default.nix)
2. **Program configs**: Add to `home/programs/<name>/<name>.nix`
3. **User services**: Edit [home/shared/services.nix](home/shared/services.nix)
4. **Niri programs**: Import in [home/wm/niri/default.nix](home/wm/niri/default.nix)
5. **Themes**: Edit [home/themes/](home/themes/)

### For System (NixOS)
1. **Global settings**: Edit [system/configuration.nix](system/configuration.nix)
2. **Machine-specific**: Edit [system/machine/arasaka/default.nix](system/machine/arasaka/default.nix)
3. **Hardware config**: [system/machine/arasaka/hardware-configuration.nix](system/machine/arasaka/hardware-configuration.nix)
4. **Window manager**: Import [system/wm/niri.nix](system/wm/niri.nix) in machine config
5. **Fonts**: Edit [system/fonts/default.nix](system/fonts/default.nix)

### Builder Pattern (Advanced)
1. **Custom builders**: [lib/overlays.nix](lib/overlays.nix)
2. **Helper functions**: [lib/default.nix](lib/default.nix)
3. **Output definitions**: [outputs/hm.nix](outputs/hm.nix), [outputs/os.nix](outputs/os.nix)

## Build Targets

### Available Home Configurations
- `.#homeConfigurations.default` - Minimal base configuration
- `.#homeConfigurations.niri` - Full Niri WM with all programs

### Available System Configurations
- `.#nixosConfigurations.arasaka` - Current machine

## File Naming Conventions

- **default.nix**: Main entry point for a directory
- **configuration.nix**: System-wide settings
- **hardware-configuration.nix**: Auto-generated hardware settings
- Files in `programs/`: `<program>/<program>.nix` (e.g., `kitty/kitty.nix`)
- Modules: Descriptive names in dedicated directories
- Config files: Use appropriate extensions (`.kdl` for niri, etc.)

## Best Practices

1. **Keep it modular**: One concern per file/directory
2. **Use imports**: Don't duplicate configuration
3. **Builder pattern**: Use `pkgs.builders.mkHome` and `mkNixos`
4. **Test incrementally**: Build after each significant change
5. **Version control**: Commit working configurations
6. **Secure secrets**: Use `home/secrets/` (gitignored)

## Quick Reference

| Task | Command |
|------|---------|
| Build Home (base) | `nix build .#homeConfigurations.default.activationPackage` |
| Build Home (niri) | `nix build .#homeConfigurations.niri.activationPackage` |
| Activate Home Manager | `./result/activate` |
| Build NixOS | `sudo nixos-rebuild switch --flake .#arasaka` |
| Test NixOS | `sudo nixos-rebuild test --flake .#arasaka` |
| Update inputs | `nix flake update` |
| Check syntax | `nix flake check` |
| Show outputs | `nix flake show` |

---

For detailed setup instructions, see [GETTING-STARTED.md](GETTING-STARTED.md).
For general information, see [README.md](README.md).
