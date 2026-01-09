# NixOS Configuration

A well-structured, beginner-friendly NixOS configuration using Flakes and Home Manager. This configuration is modeled after [gvolpe/nix-config](https://github.com/gvolpe/nix-config) with a focus on clarity and ease of management.

## ✨ Features

- **Flake-based**: Modern Nix flakes with shallow git clones for fast updates
- **Modular Structure**: Easy to add/remove components
- **Home Manager**: Complete user environment management
- **Multiple Profiles**: default, hidpi, mutable, and niri variants
- **Niri Window Manager**: Scrollable-tiling Wayland compositor with full setup
- **Theming System**: Base16 Helios colors + GTK themes (BeautyLine, Juno-ocean)
- **Custom Fonts**: System font management with Nerd Fonts
- **Well-documented**: Comprehensive guides and examples for beginners
- **Example Configs**: Kitty terminal config as template for programs/

## 🗂️ Project Structure

```
.
├── flake.nix              # Flake entry point
├── lib/                   # Shared library code
│   ├── default.nix        # Helper functions
│   ├── overlays.nix       # Package overlays and builders
│   └── schemas.nix        # Flake schema definitions
├── home/                  # Home Manager configuration
│   ├── modules/           # Custom HM modules (hidpi, dotfiles)
│   ├── programs/          # Per-application configs (kitty example)
│   ├── shared/            # Shared configuration (always applied)
│   ├── themes/            # Color schemes and GTK themes
│   └── wm/                # Window manager configs (niri)
├── system/                # NixOS system configuration
│   ├── configuration.nix  # Base system config
│   ├── fonts/             # Custom font packages
│   ├── misc/              # Miscellaneous files (sudo prompts)
│   └── wm/                # Window manager system-level configs
└── outputs/               # Build configurations
    ├── hm.nix            # Home Manager outputs (default, hidpi, niri variants)
    └── os.nix            # NixOS outputs
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
   # Standard desktop
   nix build .#homeConfigurations.default.activationPackage
   ./result/activate
   
   # Niri window manager
   nix build .#homeConfigurations.niri-default.activationPackage
   ./result/activate
   
   # HiDPI variants
   nix build .#homeConfigurations.hidpi.activationPackage
   # or
   nix build .#homeConfigurations.niri-hidpi.activationPackage
   ```
   
   **For NixOS system:**
   ```bash
   # Import system/wm/niri.nix in configuration.nix if using niri
   sudo nixos-rebuild switch --flake .#default
   ```

## 📚 Directory Guide

### `home/` - User Environment

Your personal configuration managed by Home Manager.

**Key directories:**
- `shared/` - Base configs always applied (programs.nix, default.nix)
- `programs/` - Per-app configs in dedicated folders
- `themes/` - Color schemes (Base16) and GTK themes
- `wm/` - Window manager configs (niri with complete setup)

**Difference: `shared/` vs `programs/`:**
- **shared/** = Base configuration that's always included (git, fish, etc.)
- **programs/** = Optional configs in dedicated folders with their own README
- See `home/wm/README.md` for detailed explanation

**Adding a program:**
1. Create `programs/myapp/` directory
2. Add `myapp.nix` with configuration
3. Add `README.md` documenting the program
4. Import in appropriate profile (shared or wm config)

### `system/` - System Configuration

NixOS system-wide settings.

**Key files:**
- `configuration.nix` - Global system config (with fonts and sudo prompt)
- `fonts/default.nix` - Custom font packages
- `misc/` - Miscellaneous files (groot.txt sudo prompt)
- `wm/` - Window manager system configs (niri.nix)

### `lib/` - Shared Code

Helper functions and overlays used across configurations.

**Files:**
- `default.nix` - Utility functions (exe, removeNewline, secretManager)
- `overlays.nix` - Custom builders (mkHome, mkNixos) and overlay imports
- `schemas.nix` - Flake schema definitions

### `outputs/` - Build Definitions

Defines how configurations are built and what outputs are available.

**Available profiles:**
- `default` - Standard desktop
- `hidpi` - HiDPI display support
- `mutable` - Development with mutable home directory
- `niri-default` - Niri window manager
- `niri-hidpi` - Niri + HiDPI
- `niri-mutable` - Niri + mutable home

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

- `default` - Standard desktop configuration
- `hidpi` - For high-DPI displays (2x scaling)
- `mutable` - Development mode with live-editing dotfiles
- `niri-default` - Niri window manager with standard scaling
- `niri-hidpi` - Niri window manager with HiDPI support
- `niri-mutable` - Niri with mutable home directory for development

Build a specific profile:
```bash
nix build .#homeConfigurations.hidpi.activationPackage
./result/activate
```

### Niri Window Manager

This config includes full support for [Niri](https://github.com/YaLTeR/niri), a scrollable-tiling Wayland compositor.

**Features:**
- Greetd login manager
- PipeWire audio
- Bluetooth support
- XDG portals for screen sharing
- Pre-configured keybindings (Mod+T for terminal, Mod+Q for close)

**To use Niri:**
1. Build the niri home profile: `nix build .#homeConfigurations.niri-default.activationPackage`
2. Import `system/wm/niri.nix` in your `system/configuration.nix`
3. Rebuild your system
4. Log out and select "niri" session in greetd

See [home/wm/niri/config.kdl](home/wm/niri/config.kdl) for keybindings and customization.

### System Profiles

Create different profiles for different machines by editing `outputs/os.nix`.

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
