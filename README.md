# Asthenia

A comprehensive, modular Nix configuration for both macOS and NixOS systems. This flake provides a complete starter setup with home-manager integration, automated scripts, and support for multiple hosts.

## Features

- **Cross-platform**: Unified configuration for both macOS (via nix-darwin) and NixOS
- **Modular Design**: Clean separation between system and user configurations
- **Home Manager**: Declarative user environment management
- **Automated Scripts**: Ready-to-use commands for building, switching, and maintenance
- **Multiple Host Support**: Easy configuration of different machines
- **Immutable Configuration**: Static files managed through Nix for consistency

## Project Structure

```
.
├── flake.nix              # Main flake definition with all inputs and outputs
├── flake.lock             # Locked dependency versions
├── hosts/                 # Host-specific configurations
│   ├── darwin/           # macOS system configuration
│   └── nixos/            # NixOS system configuration
├── modules/              # Reusable configuration modules
│   ├── darwin/          # macOS-specific modules
│   │   ├── casks.nix    # Homebrew casks
│   │   ├── dock/        # Dock configuration
│   │   ├── files.nix    # Static configuration files
│   │   ├── home-manager.nix # User programs and settings
│   │   └── packages.nix # System packages
│   ├── nixos/           # NixOS-specific modules
│   │   ├── config/      # Configuration files (polybar, rofi, etc.)
│   │   ├── disk-config.nix # Disk partitioning
│   │   ├── files.nix    # Static configuration files
│   │   ├── home-manager.nix # User programs and settings
│   │   └── packages.nix # System packages
│   └── shared/          # Cross-platform shared modules
├── overlays/            # Nixpkgs overlays for custom packages
├── scripts/             # Unified Nix scripts (build, apply, clean, etc.)
└── README.md           # This file
```

## Quick Start

### Prerequisites

1. **Install Nix** with flakes enabled:
   ```bash
   # macOS
   curl -L https://nixos.org/nix/install | sh

   # Linux
   curl -L https://nixos.org/nix/install | sh
   ```

2. **Enable experimental features** in `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```

### First Time Setup

1. **Clone and enter the repository**:
   ```bash
   git clone https://github.com/infktd/asthenia.git
   cd asthenia
   ```

2. **Run the interactive setup**:
   ```bash
   nix run .#apply
   ```
   This will:
   - Detect your platform (macOS/Linux)
   - Prompt for user information (username, email, etc.)
   - Configure git settings
   - Set up hostname and network interface (Linux only)

3. **Build and switch to your new configuration**:
   ```bash
   nix run .#build-switch
   ```

## Available Commands

All commands are available as flake apps and work on both platforms:

```bash
# Interactive setup (first-time only)
nix run .#apply

# Build configuration without switching
nix run .#build

# Build and switch to new configuration
nix run .#build-switch

# Clean old system generations
nix run .#clean

# Rollback to previous generation (macOS only)
nix run .#rollback
```

### Development Shell

Enter a development environment with all tools available:

```bash
nix develop
# Now you can run: apply, build, build-switch, clean, rollback
```

## Platform-Specific Setup

### macOS (Darwin)

The macOS configuration uses nix-darwin and includes:
- Homebrew integration via nix-homebrew
- Dock configuration
- System preferences
- Homebrew casks and packages

### NixOS

The NixOS configuration includes:
- Disk partitioning with disko
- BSPWM window manager with polybar
- Rofi application launcher
- Comprehensive hotkey setup

## Home Manager Configuration

User environments are managed through home-manager with:
- Shell configuration (bash/zsh)
- Editor setup (vim/emacs)
- Development tools
- Desktop applications
- Dotfile management

## 🌍 Multiple Host Support

Configure different machines with host-specific overrides:

```bash
# Build for a specific named host
nix run .#build-switch -- --host myhostname

# Or use the default platform-based configuration
nix run .#build-switch
```

See `modules/nixos/README.md` for detailed instructions on adding new hosts.

## Customization

### Adding Packages

**macOS packages** → `modules/darwin/packages.nix`  
**macOS casks** → `modules/darwin/casks.nix`  
**NixOS packages** → `modules/nixos/packages.nix`

### User Configuration

Edit `modules/darwin/home-manager.nix` or `modules/nixos/home-manager.nix` for user-specific settings.

### System Configuration

Modify `hosts/darwin/default.nix` or `hosts/nixos/default.nix` for system-wide changes.

## Essential Hotkeys (NixOS)

After setup, these hotkeys are available with BSPWM:

### Core Navigation
- **Super + Space** - Application launcher (rofi)
- **Super + Enter** - Terminal (floating)
- **Super + Ctrl + Enter** - Terminal (tiled)
- **Alt + F4** - Close window

### Window Management
- **Super + h/j/k/l** - Focus window (vim-style navigation)
- **Super + Shift + h/j/k/l** - Move window
- **Super + f** - Toggle fullscreen
- **Super + d** - Toggle floating/tiled

### Workspaces
- **Super + 1-6** - Switch workspace
- **Super + Shift + 1-6** - Move window to workspace

See `modules/nixos/README.md` for the complete hotkey reference.

## Updates

Keep your configuration current:

```bash
# Update flake inputs
nix flake update

# Rebuild and switch
nix run .#build-switch
```

## Maintenance

```bash
# Clean old generations (keeps last 7 days)
nix run .#clean

# Garbage collect (remove unused packages)
sudo nix-collect-garbage -d
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `nix run .#build-switch`
5. Submit a pull request

## License

This project is open source. Feel free to use, modify, and distribute.

## Acknowledgments

- Based on the excellent work by [dustinlyons](https://github.com/dustinlyons/nixos-config)
-  Built with ❤️ using  [nixpkgs](https://github.com/NixOS/nixpkgs), [nix-darwin](https://github.com/LnL7/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager)
