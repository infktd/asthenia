# Project Structure Overview

This document provides a visual guide to understanding the structure of this NixOS configuration.

## Directory Tree

```

├── flake.nix                    # Entry point - defines inputs and outputs
│
├── lib/                         # Shared library code
│   ├── default.nix             # Helper functions (exe, secretManager, etc.)
│   ├── overlays.nix            # Package overlays and builder functions
│   └── README.md
│
├── home/                        # Home Manager configuration (user environment)
│   ├── modules/                # Custom Home Manager modules
│   │   ├── default.nix         # Module list
│   │   ├── dotfiles.nix        # Mutable dotfiles support
│   │   ├── hidpi.nix           # HiDPI display settings
│   │   └── README.md
│   │
│   ├── programs/               # Per-application configurations
│   │   └── (add your program configs here)
│   │
│   ├── services/               # User-level systemd services
│   │   └── (add your service configs here)
│   │
│   ├── shared/                 # Base configuration for all profiles
│   │   ├── default.nix         # Main config with packages
│   │   ├── programs.nix        # Shared program settings
│   │   └── services.nix        # Shared service settings
│   │
│   ├── overlays/               # Custom package overlays
│   │   └── README.md
│   │
│   ├── scripts/                # Helper scripts
│   │   ├── default.nix
│   │   └── example-script.nix
│   │
│   ├── secrets/                # Private data (gitignored)
│   │   ├── .gitignore
│   │   └── README.md
│   │
│   └── README.md
│
├── system/                      # NixOS system configuration
│   ├── configuration.nix       # Global system configuration
│   │
│   ├── machine/                # Per-machine configurations
│   │   └── default/
│   │       ├── default.nix     # Machine-specific settings
│   │       └── hardware-configuration.nix
│   │
│   ├── modules/                # System-level modules
│   │   └── README.md
│   │
│   └── README.md
│
├── outputs/                     # Build configuration outputs
│   ├── hm.nix                  # Home Manager build definitions
│   ├── os.nix                  # NixOS build definitions
│   └── README.md
│
├── README.md                    # Main documentation
├── GETTING-STARTED.md          # Step-by-step setup guide
├── STRUCTURE.md                # This file
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
Profile Name  →  outputs/hm.nix  →  home/shared/  →  User Environment
   (default)                          + modules/
                                      + programs/
                                      + services/
```

**Build:**
```bash
nix build .#homeConfigurations.default.activationPackage
./result/activate
```

### NixOS System
```
Machine Name  →  outputs/os.nix  →  system/machine/  →  System Config
   (default)                          + configuration.nix
                                      + modules/
```

**Build:**
```bash
sudo nixos-rebuild switch --flake .#default
```

## Customization Points

### For Users (Home Manager)
1. **Base packages**: Edit `home/shared/default.nix`
2. **Program configs**: Add to `home/programs/`
3. **User services**: Add to `home/services/`
4. **Custom modules**: Add to `home/modules/`

### For System (NixOS)
1. **Global settings**: Edit `system/configuration.nix`
2. **Machine-specific**: Edit `system/machine/<name>/default.nix`
3. **System modules**: Add to `system/modules/`
4. **Hardware config**: Generated in `system/machine/<name>/hardware-configuration.nix`

## Module Import Chain

### Home Manager
```
flake.nix
  └→ outputs/hm.nix
      └→ home/shared/default.nix
          ├→ home/modules/default.nix
          │   ├→ dotfiles.nix
          │   └→ hidpi.nix
          ├→ home/shared/programs.nix
          │   └→ home/programs/*
          └→ home/shared/services.nix
              └→ home/services/*
```

### NixOS
```
flake.nix
  └→ outputs/os.nix
      └→ system/machine/default/default.nix
          ├→ hardware-configuration.nix
          └→ system/configuration.nix
              └→ system/modules/*
```

## Adding New Components

### New Program (User)
1. Create: `home/programs/myapp/default.nix`
2. Import in: `home/shared/programs.nix`
3. Build: Home Manager configuration

### New Service (User)
1. Create: `home/services/myservice/default.nix`
2. Import in: `home/shared/services.nix`
3. Build: Home Manager configuration

### New Machine
1. Create: `system/machine/mymachine/`
2. Add hardware-configuration.nix
3. Create default.nix with imports
4. Add to: `outputs/os.nix` hosts list
5. Build: NixOS configuration

### New Module (Home)
1. Create: `home/modules/mymodule.nix`
2. Add to: `home/modules/default.nix`
3. Use in: Any home configuration

### New Module (System)
1. Create: `system/modules/mymodule.nix`
2. Import in: Machine's default.nix
3. Build: NixOS configuration

## Build Targets

### Available Home Configurations
- `.#homeConfigurations.default` - Standard profile
- `.#homeConfigurations.hidpi` - HiDPI display profile
- `.#homeConfigurations.mutable` - Development profile

### Available System Configurations
- `.#nixosConfigurations.default` - Default machine

## File Naming Conventions

- **default.nix**: Main entry point for a directory
- **README.md**: Documentation for a directory
- **configuration.nix**: System-wide settings
- **hardware-configuration.nix**: Auto-generated hardware settings
- Files in `programs/`: Named after the program (e.g., `alacritty/default.nix`)
- Files in `services/`: Named after the service (e.g., `syncthing/default.nix`)
- Modules: Descriptive names (e.g., `hidpi.nix`, `dotfiles.nix`)

## Best Practices

1. **Keep it modular**: One concern per file/directory
2. **Use imports**: Don't duplicate configuration
3. **Document changes**: Add comments for non-obvious config
4. **Test incrementally**: Build after each significant change
5. **Version control**: Commit working configurations
6. **Secure secrets**: Never commit sensitive data

## Quick Reference

| Task | Command |
|------|---------|
| Build Home Manager | `nix build .#homeConfigurations.default.activationPackage` |
| Activate Home Manager | `./result/activate` |
| Build NixOS | `sudo nixos-rebuild switch --flake .#default` |
| Test NixOS | `sudo nixos-rebuild test --flake .#default` |
| Update inputs | `nix flake update` |
| Check syntax | `nix flake check` |
| Show outputs | `nix flake show` |

---

For detailed setup instructions, see [GETTING-STARTED.md](GETTING-STARTED.md).
For general information, see [README.md](README.md).
