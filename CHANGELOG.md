# Changelog

All notable changes and additions to this NixOS configuration.

## [Current] - Complete gvolpe Structure

### Added

#### Window Manager Support
- **home/wm/niri/** - Complete Niri window manager configuration
  - User environment setup with all required packages
  - KDL configuration file with keybindings
  - Session variables for Wayland
  - XDG portals configuration
- **system/wm/niri.nix** - System-level Niri support
  - Greetd login manager
  - PipeWire audio
  - Bluetooth services
  - seatd for seat management

#### Theming System
- **home/themes/colors.nix** - Base16 Helios color scheme
  - 16 color definitions for consistent theming
  - Can be imported in other configs
- **home/themes/default.nix** - GTK theme configuration
  - BeautyLine icon theme
  - Juno-ocean GTK theme
  - Dark mode preference

#### Fonts & Misc
- **system/fonts/default.nix** - Custom font packages management
- **system/misc/groot.txt** - Custom sudo prompt message with ASCII art

#### Library & Schema
- **lib/schemas.nix** - Flake schema definitions for better documentation

#### Example Configuration
- **home/programs/kitty/** - Complete Kitty terminal example
  - Full configuration with OneDark theme
  - JetBrainsMono Nerd Font
  - Serves as template for other programs

### Modified

#### Core Files
- **flake.nix**
  - Added `niri-flake` input from sodiboo/niri-flake
  - Integrated schemas for flake documentation
  
- **lib/overlays.nix**
  - Added niri-flake overlay import
  
- **outputs/hm.nix**
  - Added three new niri profiles: niri-default, niri-hidpi, niri-mutable
  
- **home/shared/default.nix**
  - Imported themes configuration
  
- **system/configuration.nix**
  - Added custom fonts integration
  - Added sudo prompt from misc/groot.txt
  - Integrated font packages

### Documentation
- Updated **README.md** with new features and structure
- Updated structure diagrams to show new directories
- Added Niri usage instructions
- Documented difference between programs/ and shared/

## Structure Philosophy

This configuration follows the gvolpe/nix-config methodology:

1. **home/shared/** - Base configurations always applied
2. **home/programs/** - Optional per-app configs in dedicated folders
3. **home/wm/** - Window manager specific configurations
4. **home/themes/** - Consistent theming across applications
5. **system/wm/** - System-level window manager services
6. **lib/** - Reusable functions and overlays

## Available Profiles

### Home Manager
- `default` - Standard desktop
- `hidpi` - HiDPI displays (2x scaling)
- `mutable` - Development with mutable dotfiles
- `niri-default` - Niri window manager
- `niri-hidpi` - Niri + HiDPI
- `niri-mutable` - Niri + mutable home

### NixOS System
- `default` - Base system configuration
- Import `system/wm/niri.nix` for Niri support

## Next Steps

1. Customize username in `home/shared/default.nix`
2. Update system settings in `system/configuration.nix`
3. Generate hardware config: `nixos-generate-config --show-hardware-config > system/hardware-configuration.nix`
4. Choose a profile and build
5. Add your own programs following the kitty example
