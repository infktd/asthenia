# Asthenia - NixOS & nix-darwin Configuration

A modern, modular Nix configuration for both **NixOS** (Linux) and **nix-darwin** (macOS), featuring comprehensive Home Manager integration, encrypted secrets management, and a well-organized flake-based setup.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Secrets Management](#secrets-management)
- [Configuration Structure](#configuration-structure)
- [Usage](#usage)
- [Testing Strategy](#testing-strategy)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## 🌟 Overview

This configuration implements a complete system setup for both Linux and macOS:

### Linux (NixOS - `arasaka`)
- **Window Manager**: Niri (Wayland compositor with scrollable tiling)
- **Desktop Environment**: DMS (Dank Material Shell) for system monitoring and widgets
- **Hardware Support**: NVIDIA GPU optimization for Wayland

### macOS (nix-darwin - `esoteric`)
- **Window Manager**: Aerospace (tiling window manager for macOS)
- **System Integration**: Homebrew casks, macOS defaults, Touch ID for sudo

### Shared
- **Configuration Management**: Flake-based with standalone Home Manager
- **Secrets Management**: sops-nix with age encryption (SSH keys, GPG keys, tokens)
- **Development Tools**: Full development environment with Neovim, Git, VSCode, Zed

### Key Features

- 🎯 **Modular Design**: Cleanly separated system and user configurations
- 🔄 **Standalone Home Manager**: User configs independent from system rebuilds
- 🔐 **Encrypted Secrets**: SSH keys, GPG keys, and tokens managed with sops-nix
- 🍎 **Cross-Platform**: Single repo for NixOS and macOS machines
- 🎨 **Comprehensive Theming**: GTK themes, fonts, and consistent styling
- ⚡ **Performance Optimized**: NVIDIA Wayland tuning (Linux), native macOS integration
- 🛠️ **Developer Friendly**: Rich development tooling and language support
- 📦 **Reproducible**: Flake-based for consistent, reproducible builds

## 🏗️ Architecture

### Configuration Philosophy

The configuration follows a **dual-layer architecture** on both platforms:

```
┌───────────────────────────────────────────────────────────────┐
│                      SYSTEM LAYER                             │
│  Linux (NixOS)              │  macOS (nix-darwin)             │
│  requires sudo              │  requires sudo                  │
│                             │                                 │
│  • Core OS config           │  • Nix daemon settings          │
│  • NVIDIA drivers           │  • Homebrew packages            │
│  • System services          │  • macOS system defaults        │
│  • WM infrastructure        │  • Touch ID for sudo            │
│                             │                                 │
│  nixos-rebuild switch       │  darwin-rebuild switch          │
│  --flake .#arasaka          │  --flake .#esoteric             │
└───────────────────────────────────────────────────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                      USER LAYER                               │
│  (Home Manager - User-level, no sudo)                         │
│                                                               │
│  • Dotfiles and configurations                                │
│  • User applications and development tools                    │
│  • Themes and appearance                                      │
│  • Secrets (SSH keys, GPG keys, tokens via sops-nix)          │
│                                                               │
│  Linux: home-manager switch --flake .#niri                    │
│  macOS: home-manager switch --flake .#aerospace               │
└───────────────────────────────────────────────────────────────┘
```

### Why Standalone Home Manager?

This configuration uses **standalone Home Manager** (not the NixOS module) for several advantages:

1. **Full Feature Access**: Access to all Home Manager options without limitations
2. **Independent Updates**: Update user configs without system rebuilds (no sudo)
3. **Per-User Customization**: Different users can have different configs
4. **Faster Iteration**: Quick config changes for development and testing

## 🚀 Quick Start

### Prerequisites

- **Linux**: NixOS installed with flakes enabled
- **macOS**: Nix installed (Determinate Nix recommended) with flakes enabled
- Git installed
- Internet connection for downloading dependencies

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone git@github.com:infktd/asthenia.git ~/.config/asthenia
   cd ~/.config/asthenia
   ```

2. **Set up secrets** (see [Secrets Management](#secrets-management) for details):
   ```bash
   mkdir -p ~/.config/sops/age
   # Add your age private key to ~/.config/sops/age/keys.txt
   ```

3. **Install system configuration**:

   **Linux (NixOS)**:
   ```bash
   sudo nixos-rebuild switch --flake .#arasaka
   ```

   **macOS (nix-darwin)**:
   ```bash
   darwin-rebuild switch --flake .#esoteric
   ```

4. **Apply user configuration**:

   **Linux**:
   ```bash
   home-manager switch --flake .#niri
   ```

   **macOS** (run twice on first setup - see [Darwin Note](#setting-up-a-new-machine)):
   ```bash
   home-manager switch --flake .#aerospace
   home-manager switch --flake .#aerospace  # Second run for sops-nix
   ```

5. **Reboot/restart** to apply all changes:

   **Linux**:
   ```bash
   systemctl reboot
   ```

   **macOS**: Open a new terminal session

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

## 🔐 Secrets Management

This configuration uses **sops-nix** with **age encryption** to securely manage secrets across all machines. Secrets are encrypted in the repository and decrypted at activation time.

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    IN THE REPO                          │
│  (encrypted, safe to push publicly)                     │
│                                                          │
│  • secrets/secrets.yaml  - Encrypted secrets            │
│  • .sops.yaml            - Age public key config        │
└─────────────────────────────────────────────────────────┘
                         ↓ decrypted at activation
┌─────────────────────────────────────────────────────────┐
│                  ON YOUR MACHINE                         │
│  (decrypted, never committed)                           │
│                                                          │
│  • ~/.config/sops/age/keys.txt  - Age private key       │
│  • ~/.ssh/id_ed25519            - SSH key (symlink)     │
│  • ~/.config/sops-nix/secrets/  - Decrypted secrets     │
└─────────────────────────────────────────────────────────┘
```

### What's Managed

| Secret | Decrypted Location | Purpose |
|--------|-------------------|---------|
| SSH Private Key | `~/.ssh/id_ed25519` | Git operations, server access |
| GPG Private Key | GPG keyring | Commit signing |
| GitHub Token | `gh` CLI auth | GitHub API access |

### Setting Up a New Machine

1. **Get the age private key** from your password manager (Bitwarden, 1Password, etc.)

2. **Create the age key file**:
   ```bash
   mkdir -p ~/.config/sops/age
   # Paste your age private key into this file:
   # AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   vim ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```

3. **Run Home Manager**:
   ```bash
   home-manager switch --flake .#<profile>
   ```

4. **Darwin only**: The first run may fail due to a sops-nix launchd PATH bug. Simply run the command again:
   ```bash
   home-manager switch --flake .#<profile>
   ```

5. **Verify secrets are working**:
   ```bash
   # SSH key
   ssh -T git@github.com

   # GPG key
   gpg --list-secret-keys

   # GitHub CLI
   gh auth status
   ```

### Adding New Secrets

1. **Edit the encrypted secrets file**:
   ```bash
   cd ~/.config/asthenia
   sops secrets/secrets.yaml
   ```
   This opens the file decrypted in your editor. Add your secret, save, and close - sops re-encrypts automatically.

2. **Add the secret definition** in `home/shared/secrets.nix`:
   ```nix
   sops.secrets.my_new_secret = {
     path = "${homeDir}/.config/app/secret-file";
     mode = "0600";
   };
   ```

3. **Run home-manager switch** to deploy.

### Forking This Repo

If you fork this repo, you'll need to set up your own secrets:

1. **Generate a new age keypair**:
   ```bash
   age-keygen -o ~/.config/sops/age/keys.txt
   age-keygen -y ~/.config/sops/age/keys.txt  # Shows public key
   ```

2. **Update `.sops.yaml`** with your age public key:
   ```yaml
   keys:
     - &master age1your_public_key_here
   ```

3. **Create your secrets file**:
   ```bash
   cd ~/.config/asthenia
   sops secrets/secrets.yaml
   ```
   Add your secrets (SSH key, GPG key, tokens, etc.)

4. **Store your age private key** securely in a password manager.

### Security Model

- **Age encryption**: X25519 + ChaCha20-Poly1305 (same crypto as Signal/WireGuard)
- **Single master key**: One age key decrypts all secrets on all your machines
- **No secrets in git history**: Only encrypted blobs are committed
- **Risk surface**: Only your age private key needs protection (keep it in a password manager with strong 2FA)

## 📁 Configuration Structure

```
.
├── flake.nix                    # Main flake entry point
├── .sops.yaml                   # Sops-nix encryption config (age public key)
├── secrets/                     # Encrypted secrets (safe to commit)
│   └── secrets.yaml             # Encrypted SSH key, GPG key, tokens
├── lib/                         # Shared libraries and utilities
│   ├── default.nix              # Custom library functions
│   ├── overlays.nix             # Nixpkgs overlays and builder functions
│   └── schemas.nix              # Flake schema definitions
├── outputs/                     # Flake output builders
│   ├── hm.nix                   # Home Manager configuration builder
│   ├── os.nix                   # NixOS configuration builder
│   └── darwin.nix               # nix-darwin configuration builder
├── system/                      # System-level configuration
│   ├── configuration.nix        # Base NixOS configuration
│   ├── fonts/                   # System-wide font packages
│   ├── machine/                 # Machine-specific configs
│   │   ├── arasaka/             # Linux machine (NixOS)
│   │   │   ├── default.nix      # Machine imports
│   │   │   ├── hardware-configuration.nix
│   │   │   └── nvidia.nix       # NVIDIA driver settings
│   │   └── esoteric/            # macOS machine (nix-darwin)
│   │       ├── default.nix      # Darwin system config
│   │       └── homebrew.nix     # Homebrew casks and formulae
│   └── wm/                      # Window manager system integration
│       └── niri.nix             # Niri system services (Linux)
└── home/                        # User-level Home Manager configuration
    ├── shared/                  # Shared user config (all profiles)
    │   ├── default.nix          # Base user configuration
    │   ├── programs.nix         # Program imports
    │   ├── services.nix         # User services
    │   └── secrets.nix          # Sops-nix secrets configuration
    ├── programs/                # Individual program configurations
    │   ├── alacritty/           # Terminal emulator
    │   ├── chrome/              # Chrome browser (Linux)
    │   ├── discord/             # Discord client (Linux, nixcord)
    │   ├── dms/                 # DMS widgets (Linux)
    │   ├── fuzzle/              # Application launcher (Linux)
    │   ├── git/                 # Git + GPG signing configuration
    │   ├── vscode/              # VS Code
    │   ├── yazi/                # File manager
    │   ├── zellij/              # Terminal multiplexer
    │   └── zsh/                 # Shell configuration
    ├── scripts/                 # Custom user scripts
    │   ├── default.nix          # Script package definitions
    │   └── asthenia.nix         # Rebuild helper script
    ├── themes/                  # Theming configuration
    │   ├── default.nix          # GTK themes and icons
    │   └── colors.nix           # Color schemes
    └── wm/                      # Window manager user configuration
        ├── niri/                # Niri settings (Linux)
        │   ├── default.nix
        │   └── config/          # Niri KDL configuration files
        └── aerospace/           # Aerospace settings (macOS)
            └── default.nix
```

## 💻 Usage

### System Updates

**Linux (NixOS)**:
```bash
sudo nixos-rebuild switch --flake .#arasaka
```

**macOS (nix-darwin)**:
```bash
darwin-rebuild switch --flake .#esoteric
```

**User configuration (both platforms)**:
```bash
# Linux
home-manager switch --flake .#niri

# macOS
home-manager switch --flake .#aerospace
```

**Update flake inputs**:
```bash
nix flake update
```

### Available Home Manager Profiles

The configuration provides multiple Home Manager profiles:

#### Linux
1. **`default`**: Basic user configuration without window manager
   ```bash
   home-manager switch --flake .#default
   ```

2. **`niri`**: Full Niri window manager configuration (recommended)
   ```bash
   home-manager switch --flake .#niri
   ```

#### macOS
1. **`default-darwin`**: Basic user configuration without window manager
   ```bash
   home-manager switch --flake .#default-darwin
   ```

2. **`aerospace`**: Full Aerospace tiling window manager configuration (recommended)
   ```bash
   home-manager switch --flake .#aerospace
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

**Note**: This configuration includes machine-specific settings:
- **`arasaka`** (Linux): NVIDIA GPU configuration for Wayland
- **`esoteric`** (macOS): Apple Silicon optimizations

You'll need to adapt hardware-specific settings when adding new machines. See [Customization](#customization) for details.
