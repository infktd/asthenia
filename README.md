# Asthenia - NixOS Configuration

A modern, modular NixOS configuration featuring the Niri window manager, comprehensive Home Manager integration, and a well-organized flake-based setup.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Configuration Structure](#configuration-structure)
- [Usage](#usage)
- [Testing Strategy](#testing-strategy)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## 🌟 Overview

This configuration implements a complete NixOS system with:

- **Window Manager**: Niri (Wayland compositor with scrollable tiling)
- **Desktop Environment**: DMS (Dank Material Shell) for system monitoring and widgets
- **Configuration Management**: Flake-based with Home Manager integration
- **Hardware Support**: NVIDIA GPU optimization for Wayland
- **Development Tools**: Full development environment with Neovim (nvf), Git, VSCode

### Key Features

- 🎯 **Modular Design**: Cleanly separated system and user configurations
- 🔄 **Standalone Home Manager**: User configs independent from system rebuilds
- 🎨 **Comprehensive Theming**: GTK themes, fonts, and consistent styling
- ⚡ **Performance Optimized**: NVIDIA Wayland tuning and aggressive performance settings
- 🛠️ **Developer Friendly**: Rich development tooling and language support
- 📦 **Reproducible**: Flake-based for consistent, reproducible builds

## 🏗️ Architecture

### Configuration Philosophy

The configuration follows a **dual-layer architecture**:

```
┌─────────────────────────────────────────────────────┐
│                   SYSTEM LAYER                      │
│  (NixOS - Root-level, requires sudo)               │
│                                                      │
│  • Core OS configuration                            │
│  • Hardware drivers (NVIDIA)                        │
│  • System services (greetd, polkit)                 │
│  • Window manager infrastructure                    │
│                                                      │
│  Apply: sudo nixos-rebuild switch --flake .#arasaka │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│                   USER LAYER                        │
│  (Home Manager - User-level, no sudo)              │
│                                                      │
│  • Dotfiles and configurations                      │
│  • User applications                                │
│  • Themes and appearance                            │
│  • Development environments                         │
│                                                      │
│  Apply: home-manager switch --flake .#niri          │
└─────────────────────────────────────────────────────┘
```

### Why Standalone Home Manager?

This configuration uses **standalone Home Manager** (not the NixOS module) for several advantages:

1. **Full Feature Access**: Access to all Home Manager options without limitations
2. **Independent Updates**: Update user configs without system rebuilds (no sudo)
3. **Per-User Customization**: Different users can have different configs
4. **Faster Iteration**: Quick config changes for development and testing

## 🚀 Quick Start

### Prerequisites

- NixOS installed with flakes enabled
- Git installed
- Internet connection for downloading dependencies

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo> ~/Projects/acidBurn
   cd ~/Projects/acidBurn
   ```

2. **Install system configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .#arasaka
   ```

3. **Install Home Manager** (if not already installed):
   ```bash
   nix profile install nixpkgs#home-manager
   ```

4. **Apply user configuration**:
   ```bash
   home-manager switch --flake .#niri
   ```

5. **Reboot** to start the Niri session:
   ```bash
   systemctl reboot
   ```

### Using the Asthenia Helper Script

The configuration includes a convenient helper script `asthenia` for managing rebuilds:

```bash
# Switch NixOS only
asthenia --switch nixos

# Switch Home Manager (auto-detects current profile)
asthenia --switch hm

# Switch Home Manager to specific profile
asthenia --switch hm niri

# Switch both system and user configs
asthenia --switch all

# Update flake inputs before switching
asthenia --update --switch all

# Show help
asthenia --help
```

## 📁 Configuration Structure

```
.
├── flake.nix                    # Main flake entry point
├── lib/                         # Shared libraries and utilities
│   ├── default.nix              # Custom library functions
│   ├── overlays.nix             # Nixpkgs overlays and builder functions
│   └── schemas.nix              # Flake schema definitions
├── outputs/                     # Flake output builders
│   ├── hm.nix                   # Home Manager configuration builder
│   └── os.nix                   # NixOS configuration builder
├── system/                      # System-level NixOS configuration
│   ├── configuration.nix        # Base system configuration
│   ├── fonts/                   # System-wide font packages
│   ├── machine/                 # Machine-specific configs
│   │   └── arasaka/             # Per-machine customization
│   │       ├── default.nix      # Machine imports
│   │       ├── hardware-configuration.nix  # Hardware config
│   │       └── nvidia.nix       # NVIDIA driver settings
│   └── wm/                      # Window manager system integration
│       └── niri.nix             # Niri system services and infrastructure
└── home/                        # User-level Home Manager configuration
    ├── shared/                  # Shared user config (all profiles)
    │   ├── default.nix          # Base user configuration
    │   ├── programs.nix         # Program imports
    │   └── services.nix         # User services
    ├── programs/                # Individual program configurations
    │   ├── alacritty/           # Terminal emulator
    │   ├── chrome/              # Chrome browser
    │   ├── discord/             # Discord client (nixcord)
    │   ├── dms/                 # DMS user configuration
    │   ├── fuzzle/              # Fuzzle app
    │   ├── git/                 # Git configuration
    │   ├── nvf/                 # Neovim configuration (nvf)
    │   ├── obsidian/            # Obsidian notes
    │   ├── vscode/              # VS Code
    │   ├── yazi/                # File manager
    │   └── zsh/                 # Shell configuration
    ├── scripts/                 # Custom user scripts
    │   ├── default.nix          # Script package definitions
    │   └── asthenia.nix         # Rebuild helper script
    ├── themes/                  # Theming configuration
    │   ├── default.nix          # GTK themes and icons
    │   └── colors.nix           # Color schemes
    └── wm/                      # Window manager user configuration
        └── niri/                # Niri user settings
            ├── default.nix      # User-level niri config
            └── config/          # Niri KDL configuration files
                ├── config.kdl   # Main config (imports others)
                ├── input.kdl    # Input device configuration
                ├── keybindings.kdl  # Keyboard shortcuts
                ├── layout.kdl   # Window layout rules
                └── outputs.kdl  # Monitor configuration
```

## 💻 Usage

### System Updates

**Update system configuration only**:
```bash
sudo nixos-rebuild switch --flake .#arasaka
```

**Update user configuration only**:
```bash
home-manager switch --flake .#niri
```

**Update flake inputs**:
```bash
nix flake update
```

### Available Home Manager Profiles

The configuration provides multiple Home Manager profiles:

1. **`default`**: Basic user configuration without window manager
   ```bash
   home-manager switch --flake .#default
   ```

2. **`niri`**: Full Niri window manager configuration (recommended)
   ```bash
   home-manager switch --flake .#niri
   ```

### Testing Changes

To test configuration changes without switching:

**Test system config**:
```bash
sudo nixos-rebuild test --flake .#arasaka
```

**Build without switching**:
```bash
nix build .#nixosConfigurations.arasaka.config.system.build.toplevel
nix build .#homeConfigurations.niri.activationPackage
```

## 🧪 Testing Strategy

### Testing After Changes

After making changes, follow this testing sequence:

```bash
# 1. Check flake syntax
nix flake check

# 2. Build configs to verify syntax
nix build .#nixosConfigurations.arasaka.config.system.build.toplevel
nix build .#homeConfigurations.niri.activationPackage

# 3. Test system changes (doesn't persist after reboot)
sudo nixos-rebuild test --flake .#arasaka

# 4. If test succeeds, switch permanently
sudo nixos-rebuild switch --flake .#arasaka

# 5. Apply user changes
home-manager switch --flake .#niri
```

## 🎨 Customization

### Adding a New Machine

1. Create machine directory:
   ```bash
   mkdir -p system/machine/new-machine
   ```

2. Create [`system/machine/new-machine/default.nix`](system/machine/new-machine/default.nix):
   ```nix
   { config, lib, pkgs, ... }:
   {
     networking.hostName = "new-machine";
     imports = [
       ./hardware-configuration.nix
       # Add window manager or other modules as needed
     ];
   }
   ```

3. Generate hardware config:
   ```bash
   nixos-generate-config --show-hardware-config > system/machine/new-machine/hardware-configuration.nix
   ```

4. Add to [`outputs/os.nix`](outputs/os.nix):
   ```nix
   hosts = [ "arasaka" "new-machine" ];
   ```

### Adding New Programs

1. Create program directory:
   ```bash
   mkdir -p home/programs/new-program
   ```

2. Create configuration file:
   ```nix
   # home/programs/new-program/new-program.nix
   { pkgs, ... }:
   {
     programs.new-program = {
       enable = true;
       # ... configuration
     };
   }
   ```

3. Import in [`home/shared/programs.nix`](home/shared/programs.nix):
   ```nix
   imports = [
     # ... existing imports
     ../programs/new-program/new-program.nix
   ];
   ```

### Customizing Niri

Niri configuration is split into modular KDL files in [`home/wm/niri/config/`](home/wm/niri/config/):

- **`config.kdl`**: Main file that imports all modules
- **`input.kdl`**: Mouse, touchpad, keyboard input settings
- **`keybindings.kdl`**: Keyboard shortcuts
- **`layout.kdl`**: Window layout and behavior rules
- **`outputs.kdl`**: Monitor configuration

Edit these files directly and run `home-manager switch --flake .#niri` to apply.

### Changing Themes

Edit [`home/themes/default.nix`](home/themes/default.nix) to change:
- GTK theme
- Icon theme
- Cursor theme
- Font settings

## 🔧 Troubleshooting

### Home Manager Command Not Found

If `home-manager` command is not available:

```bash
# Install Home Manager
nix profile install nixpkgs#home-manager

# Or use nix run
nix run nixpkgs#home-manager -- switch --flake .#niri
```

### Flake Outputs Not Showing

If `nix flake show` shows "unknown" for homeConfigurations:

This is expected behavior. The configurations are built lazily. You can still use them:

```bash
# These work even if show reports "unknown"
home-manager switch --flake .#niri
nix build .#homeConfigurations.niri.activationPackage
```

### NVIDIA Issues on Wayland

If you experience NVIDIA issues:

1. Check driver is loaded:
   ```bash
   lsmod | grep nvidia
   ```

2. Verify environment variables are set:
   ```bash
   echo $LIBVA_DRIVER_NAME  # Should be "nvidia"
   echo $GBM_BACKEND        # Should be "nvidia-drm"
   ```

3. Check [`system/machine/arasaka/nvidia.nix`](system/machine/arasaka/nvidia.nix) settings

### Niri Not Starting

1. Check greetd service:
   ```bash
   systemctl status greetd
   ```

2. Verify niri-session is available:
   ```bash
   which niri-session
   ```

3. Check session logs:
   ```bash
   journalctl --user -u niri -e
   ```

### DMS Service Issues

1. Check service status:
   ```bash
   systemctl --user status dms.service
   ```

2. Verify service is enabled:
   ```bash
   systemctl --user list-unit-files | grep dms
   ```

3. Restart service:
   ```bash
   systemctl --user restart dms.service
   ```

## 📚 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Niri Documentation](https://github.com/YaLTeR/niri)
- [Flakes Guide](https://nixos.wiki/wiki/Flakes)

## 🤝 Contributing

When contributing to this configuration:

1. Test all changes using the testing strategy above
2. Document any new features in this README
3. Add inline comments to complex Nix expressions
4. Keep system and user layers properly separated
5. Update the structure diagram if adding new directories

## 📝 License

This configuration is provided as-is for personal use. Feel free to fork and adapt to your needs.

---

**Note**: This configuration is designed for the `arasaka` machine with specific hardware (NVIDIA GPU). You'll need to adapt hardware-specific settings for your system.
