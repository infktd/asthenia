````markdown
# home/

This directory contains your Home Manager configuration for managing user-level packages, dotfiles, and services.

## Structure

### modules/
Custom Home Manager modules defining reusable options:
- `dotfiles.nix` - Mutable dotfiles support
- `hidpi.nix` - HiDPI display settings

### programs/
Per-application configuration. Each subdirectory contains settings for a specific program.

**Examples to add:**
- `programs/alacritty/` - Terminal emulator config
- `programs/neovim/` - Editor configuration
- `programs/firefox/` - Browser settings

### services/
User-level systemd services and service configurations.

**Examples to add:**
- `services/dunst/` - Notification daemon
- `services/syncthing/` - File synchronization

### shared/
Base configuration imported by all home profiles:
- `default.nix` - Main shared config with packages
- `programs.nix` - Shared program configurations
- `services.nix` - Shared service configurations

### overlays/
Local Nix overlays for custom packages or package modifications.

**Usage:**
Create overlay files here and import them in `lib/overlays.nix`.

### scripts/
Helper scripts used by home modules.

### secrets/
**Important:** This directory should contain sensitive data and be excluded from version control.

Add to `.gitignore`:
```
home/secrets/
```

## Getting Started

1. **Edit shared/default.nix:**
   - Change `username` to your username
   - Set appropriate `stateVersion`

2. **Configure programs:**
   - Add program configs under `programs/`
   - Import them in `shared/programs.nix`

3. **Add services:**
   - Create service configs under `services/`
   - Import them in `shared/services.nix`

## Usage Examples

### Adding a new program

Create `programs/alacritty/default.nix`:
```nix
{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 12;
    };
  };
}
```

Then import in `shared/programs.nix`:
```nix
{
  imports = [
    ../programs/alacritty
  ];
  
  # ... rest of config
}
```

### Building your configuration

```bash
# Build home configuration
nix build .#homeConfigurations.default.activationPackage

# Activate the configuration
./result/activate
```

## Notes

- This folder works with Nix flakes and Home Manager
- Keep sensitive data in `secrets/` directory
- Per-app settings go in `programs/`
- System services go in `services/`

````