# Configuration System

## Overview

The asthenia NixOS configuration now uses a centralized parameterization system that allows easy customization without editing multiple files. All user-configurable variables are stored in `variables.nix`, and a TUI (Terminal User Interface) script is provided for interactive configuration.

## Quick Start

### Interactive Configuration

Run the configuration wizard to update your settings:

```bash
cd ~/.config/asthenia
./home/scripts/configure-asthenia.sh
```

The script will guide you through all configurable options including:
- User information (username, email, etc.)
- System settings (hostname, timezone, locale)
- Window manager selection (Niri, Hyprland, or headless)
- Hardware features (GPU, audio, Bluetooth, printing)
- Development tools and languages
- Applications (browsers, communication, media, terminal, etc.)
- Gaming support
- Secrets management
- Advanced options (garbage collection, auto-upgrade, etc.)

### Manual Configuration

Alternatively, you can directly edit `variables.nix`:

```bash
vim ~/.config/asthenia/variables.nix
```

## Variables Structure

The `variables.nix` file is organized into the following sections:

### User Information
```nix
user = {
  username = "infktd";
  fullName = "User";
  email = "user@example.com";
  homeDirectory = "/home/infktd";
};
```

### System Configuration
```nix
system = {
  hostname = "arasaka";
  architecture = "x86_64-linux";
  stateVersion = "24.05";
};
```

### Window Manager Selection
```nix
windowManager = {
  selected = "niri";  # Options: "niri", "hyprland", null
  
  enable = {
    niri = true;
    hyprland = false;
  };
};
```

### Hardware Features
```nix
hardware = {
  gpu = {
    nvidia = true;
    amd = false;
    intel = false;
  };
  
  audio = {
    enable = true;
    pipewire = true;
  };
  
  bluetooth.enable = true;
  printing.enable = false;
};
```

### Development Tools
```nix
development = {
  enable = true;
  
  languages = {
    python = true;
    nodejs = true;
    rust = false;
    go = false;
    java = false;
  };
  
  editors = {
    vscode = true;
    neovim = true;
  };
};
```

### Applications
```nix
applications = {
  browsers = {
    chromium = true;
    firefox = false;
  };
  
  communication = {
    discord = true;
    signal = true;
    telegram = false;
  };
  
  media = {
    vlc = true;
    mpv = false;
    spotify = false;
  };
  
  terminal = {
    kitty = true;
    alacritty = false;
    wezterm = false;
  };
  
  fileManager = {
    yazi = true;
    nautilus = false;
  };
  
  other = {
    obsidian = true;
  };
};
```

### Gaming
```nix
gaming = {
  enable = false;
  steam = false;
  lutris = false;
};
```

### Advanced Options
```nix
advanced = {
  allowUnfree = true;
  experimentalFeatures = true;
  autoUpgrade = false;
  autoGarbageCollect = true;
  garbageCollectDays = 7;
};
```

## Window Manager Support

The configuration supports multiple window managers:

### Niri (Default)
Niri is a scrollable-tiling Wayland compositor. Configuration is located in `home/wm/niri/`.

To enable Niri:
```nix
windowManager = {
  selected = "niri";
  enable.niri = true;
};
```

### Hyprland
Hyprland is a dynamic tiling Wayland compositor. Configuration will be added to `home/wm/hyprland/`.

To enable Hyprland:
```nix
windowManager = {
  selected = "hyprland";
  enable.hyprland = true;
};
```

### Headless (No Window Manager)
For servers or headless setups, set:
```nix
windowManager = {
  selected = null;
};
```

## Building and Applying Changes

After modifying `variables.nix` (either manually or via the TUI), rebuild your system:

```bash
# For NixOS system configuration
sudo nixos-rebuild switch --flake .#<hostname>

# For Home Manager only
nix build .#homeConfigurations.<config-name>.activationPackage
./result/activate
```

The hostname is automatically read from `variables.nix`.

## Adding New Machines

To add a new machine:

1. Update the hostname in `variables.nix`:
   ```nix
   system.hostname = "new-hostname";
   ```

2. Create a machine-specific directory:
   ```bash
   mkdir -p system/machine/new-hostname
   ```

3. Add `default.nix` and `hardware-configuration.nix` to the new directory.

4. The flake will automatically detect and build the configuration.

## Architecture

The parameterization system works as follows:

1. **variables.nix**: Central configuration file with all user-customizable variables
2. **flake.nix**: Imports `variables.nix` and passes it to all modules
3. **outputs/**: Builder modules receive `vars` and pass it to configurations
4. **system/configuration.nix**: Uses variables for system-level configuration
5. **home/**: Home Manager modules use variables for user-level configuration
6. **configure-asthenia.sh**: Interactive TUI for updating variables

## Design Principles

1. **Single Source of Truth**: All configurable parameters are in `variables.nix`
2. **Declarative**: Variables describe what you want, not how to achieve it
3. **Modular**: Easy to add new window managers or configurations
4. **User-Friendly**: TUI script for non-technical users
5. **Flexible**: Direct file editing for advanced users

## Future Enhancements

- Add more window manager support (Sway, i3, etc.)
- Machine-specific variable overrides
- Profile support (work, gaming, minimal, etc.)
- Web-based configuration UI
- Automated hardware detection and variable suggestion
