# NixOS Configuration

A well-structured, beginner-friendly NixOS configuration using Flakes and Home Manager. This configuration is modeled after [gvolpe/nix-config](https://github.com/gvolpe/nix-config) with a focus on clarity and ease of management.

## ✨ Features

- **Flake-based**: Modern Nix flakes with shallow git clones for fast updates
- **Builder Pattern**: Custom `mkHome` and `mkNixos` builders in overlays
- **Modular Structure**: Easy to add/remove components
- **Home Manager**: Complete user environment management
- **Two Configurations**: `default` (shared base) and `niri` (window manager)
- **Niri Window Manager**: Scrollable-tiling Wayland compositor with full setup
- **Theming System**: Base16 Helios colors + GTK themes
- **Custom Fonts**: System font management with Nerd Fonts
- **Multiple Programs**: Firefox, Discord, Obsidian, VSCode, nvf (Neovim), Yazi, Kitty, and more
- **Well-documented**: Comprehensive guides and examples

## 🗂️ Project Structure

```
.
├── flake.nix              # Flake entry point with builder-based outputs
├── lib/                   # Shared library code
│   ├── default.nix        # Helper functions (exe, secretManager, removeNewline)
│   ├── overlays.nix       # Custom builders (mkHome, mkNixos) and overlays
│   └── schemas.nix        # Flake schema definitions
├── home/                  # Home Manager configuration
│   ├── programs/          # Per-application configs
│   │   ├── discord/       # Discord (via nixcord)
│   │   ├── dms/           # DankMaterialShell (quickshell)
│   │   ├── firefox/       # Firefox browser
│   │   ├── fuzzle/        # Fuzzle launcher
│   │   ├── git/           # Git configuration
│   │   ├── kitty/         # Kitty terminal
│   │   ├── nvf/           # Neovim (via nvf)
│   │   ├── obsidian/      # Obsidian notes
│   │   ├── vscode/        # VS Code editor
│   │   └── yazi/          # Yazi file manager
│   ├── scripts/           # Helper scripts
│   ├── secrets/           # Private data (gitignored)
│   ├── shared/            # Base configuration (programs, services)
│   ├── themes/            # Color schemes (Base16 Helios) and GTK themes
│   └── wm/                # Window manager configs
│       └── niri/          # Niri configuration with config.kdl
├── system/                # NixOS system configuration
│   ├── configuration.nix  # Base system config
│   ├── fonts/             # Custom font packages
│   ├── machine/           # Per-machine configurations
│   │   └── arasaka/       # Machine-specific setup
│   ├── misc/              # Miscellaneous (groot.txt sudo prompt)
│   └── wm/                # Window manager system configs
│       └── niri.nix       # Niri system integration
└── outputs/               # Build configurations
    ├── hm.nix            # Home Manager outputs (default, niri)
    └── os.nix            # NixOS outputs (arasaka)
```

## 🚀 Quick Start

### Prerequisites

- NixOS installed (or nix with flakes enabled)
- Basic understanding of Nix

### Initial Setup

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url> ~/.config/nix-config
   cd ~/.config/nix-config
   ```

2. **Customize your configuration:**
   - Edit `home/shared/default.nix` and change `username`
   - Edit `system/configuration.nix` and change `hostName` and user settings
   - Generate hardware config:
     ```bash
     nixos-generate-config --show-hardware-config > system/machine/default/hardware-configuration.nix
     ```

3. **Build and activate:**
   
   **For Home Manager only:**
   ```bash
   # Shared base configuration
   nix build .#homeConfigurations.default.activationPackage
   ./result/activate
   
   # Niri window manager (includes all programs)
   nix build .#homeConfigurations.niri.activationPackage
   ./result/activate
   ```
   
   **For NixOS system:**
   ```bash
   # Import system/wm/niri.nix in configuration.nix if using niri
   sudo nixos-rebuild switch --flake .#arasaka
   ```

## 📚 Directory Guide

### `home/` - User Environment

Your personal configuration managed by Home Manager.

**Key directories:**
- `shared/` - Base configs (programs.nix, services.nix, default.nix)
  - Imported by all configurations
  - Contains base packages and settings
- `programs/` - Per-app configs in dedicated folders
  - discord, dms, firefox, fuzzle, git, kitty, nvf, obsidian, vscode, yazi
  - Each program in its own directory with .nix file
- `themes/` - Color schemes (Base16 Helios) and GTK themes
- `wm/niri/` - Complete Niri window manager setup
  - config.kdl for keybindings and layout
  - Imports all programs (firefox, kitty, nvf, etc.)

**Configuration Architecture:**
- **default**: Only imports `shared/` (minimal base)
- **niri**: Imports `shared/` + all programs + niri setup

**Adding a program:**
1. Create `programs/myapp/myapp.nix`
2. Add configuration in the file
3. Import in `wm/niri/default.nix` or `shared/programs.nix`
4. Rebuild configuration

### `system/` - System Configuration

NixOS system-wide settings.

**Key files:**
- `configuration.nix` - Global system config (with fonts and sudo prompt)
- `fonts/default.nix` - Custom font packages
- `misc/` - Miscellaneous files (groot.txt sudo prompt)
- `wm/` - Window manager system configs (niri.nix)

### `lib/` - Shared Code

Helper functions and builder pattern implementation.

**Files:**
- `default.nix` - Utility functions:
  - `exe` - Extract executable path from package
  - `removeNewline` - String manipulation helper
  - `secretManager.readSecret` - Read secrets from files
- `overlays.nix` - Custom builders exposed via pkgs.builders:
  - `mkHome` - Build Home Manager configurations
  - `mkNixos` - Build NixOS system configurations
  - Integrates lib extensions and niri overlay
- `schemas.nix` - Flake schema for custom outputs

### `outputs/` - Build Definitions

Defines how configurations are built using the builder pattern.

**hm.nix - Home Manager outputs:**
- `default` - Minimal shared configuration
- `niri` - Full setup with window manager and all programs

**os.nix - NixOS outputs:**
- `arasaka` - Current machine configuration
- Automatically merges all hosts from machine/ directory

## 🎯 Common Tasks

### Update System

```bash
# Update flake inputs
nix flake update

# Rebuild with new inputs
sudo nixos-rebuild switch --flake .#default
```

### Add a Package

**System-wide:**
Edit `system/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  htop
  # your package here
];
```

**User-level:**
Edit `home/shared/default.nix`:
```nix
packages = with pkgs; [
  firefox
  # your package here
];
```

### Enable a Service

**System service:**
```nix
# In system/configuration.nix
services.openssh.enable = true;
```

**User service:**
```nix
# In home/shared/services.nix
services.syncthing.enable = true;
```

### Create a Custom Module

**Home Manager module** (`home/modules/mymodule.nix`):
```nix
{ config, lib, ... }:

{
  options.mymodule = {
    enable = lib.mkEnableOption "my custom module";
  };

  config = lib.mkIf config.mymodule.enable {
    # your configuration
  };
}
```

**System module** (`system/modules/mymodule.nix`):
```nix
{ config, lib, pkgs, ... }:

{
  # System-level configuration
}
```

## 🔧 Configuration Profiles

### Home Manager Profiles

- `default` - Base configuration with shared programs only
- `niri` - Complete setup with Niri WM and all programs

Build a profile:
```bash
# Minimal base
nix build .#homeConfigurations.default.activationPackage

# Full Niri setup
nix build .#homeConfigurations.niri.activationPackage

# Then activate
./result/activate
```

### Niri Window Manager

This config includes full support for [Niri](https://github.com/YaLTeR/niri), a scrollable-tiling Wayland compositor.

**Included Programs:**
- Firefox, Discord (nixcord), Obsidian, VS Code
- Kitty terminal, Yazi file manager
- nvf (Neovim configuration framework)
- Fuzzle launcher, DankMaterialShell

**System Features:**
- Greetd login manager with niri session
- PipeWire audio with control utilities
- Bluetooth support
- XDG portals for screen sharing
- Polkit authentication agent

**To use Niri:**
1. Build the niri home profile: `nix build .#homeConfigurations.niri.activationPackage && ./result/activate`
2. Import `system/wm/niri.nix` in your machine's `default.nix`
3. Rebuild system: `sudo nixos-rebuild switch --flake .#arasaka`
4. Log out and select "niri" session

See [home/wm/niri/config.kdl](home/wm/niri/config.kdl) for keybindings.
Config split into modular files in [home/wm/niri/config/](home/wm/niri/config/).

### System Profiles

**Current machine:** `arasaka`

Create new machines:
1. Add directory: `system/machine/<hostname>/`
2. Add `default.nix` and `hardware-configuration.nix`
3. Add hostname to `outputs/os.nix` hosts list
4. Build: `sudo nixos-rebuild switch --flake .#<hostname>`

## 🛠️ Troubleshooting

### Configuration doesn't build

```bash
# Check for syntax errors
nix flake check

# Build with verbose output
nix build .#homeConfigurations.default.activationPackage --show-trace
```

### Need to rollback

```bash
# NixOS system
sudo nixos-rebuild switch --rollback

# Or boot into previous generation from GRUB
```

### Secrets not working

- Ensure `home/secrets/` is gitignored
- Check file permissions (should be 600 or 400)
- Verify file paths in your configuration

## 📖 Learning Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Wiki](https://nixos.wiki/)
- [Original inspiration: gvolpe/nix-config](https://github.com/gvolpe/nix-config)

## 🔐 Security Notes

- **Never commit secrets** - Use `home/secrets/` for sensitive data
- Keep `home/secrets/` out of version control
- Consider using `sops-nix` or `age` for encrypted secrets
- Review firewall settings in `system/configuration.nix`

## 📝 Customization Tips

1. **Start simple** - Begin with the default configuration
2. **Add incrementally** - Add one program or service at a time
3. **Test changes** - Use `nixos-rebuild test` before `switch`
4. **Document changes** - Add comments explaining non-obvious configuration
5. **Use modules** - Keep related configuration together in modules

## 🤝 Contributing

This is a personal configuration, but feel free to:
- Use it as a template for your own config
- Submit issues for clarification
- Share improvements via pull requests

## 📄 License

This configuration is provided as-is for educational purposes. Adapt and modify as needed for your own use.

## 🙏 Credits

This configuration structure is inspired by [gvolpe/nix-config](https://github.com/gvolpe/nix-config). Check out his repository for more advanced configurations and ideas.
