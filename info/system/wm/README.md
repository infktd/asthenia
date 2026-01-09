````markdown
# system/wm/

This directory contains window manager configurations at the system level.

## Purpose

System-level configurations for window managers and display servers that need to be enabled system-wide.

## Available Configurations

### niri.nix
Niri is a scrollable-tiling Wayland compositor.

**Features configured:**
- Wayland environment packages
- Niri program enablement
- Greetd login manager
- Bluetooth support
- Pipewire audio
- Seatd for non-root access

**Usage:**
```nix
# In system/machine/<your-machine>/default.nix
imports = [
  ../../wm/niri.nix
];
```

## Adding Other Window Managers

Create a new file for each window manager (e.g., `hyprland.nix`, `sway.nix`):

```nix
{ pkgs, ... }:

{
  programs.hyprland.enable = true;
  
  # Add window manager specific system configuration
}
```

## Notes

- **System WM configs** are imported at the machine level
- **User WM configs** go in `home/wm/`
- System configs enable services, user configs set up the environment
- Only one window manager should typically be active per machine

````