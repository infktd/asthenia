````markdown
# home/modules/

This directory contains custom Home Manager modules that define reusable configuration options.

## Available Modules

### dotfiles.nix
Manages dotfile handling with support for mutable (symlinked) or immutable (copied) configs.

**Options:**
- `dotfiles.mutable` (bool): Enable live-editing of dotfiles
- `dotfiles.path` (path): Location of your dotfiles directory

**Usage:**
```nix
{
  dotfiles = {
    mutable = true;
    path = "/home/user/nix-config/home";
  };
}
```

### hidpi.nix
Configuration for high-DPI displays.

**Options:**
- `hidpi` (bool): Enable HiDPI-specific settings

**Usage:**
```nix
{
  hidpi = true;
}
```

## Adding New Modules

1. Create a new `.nix` file in this directory
2. Define options using `lib.mkOption` or `lib.mkEnableOption`
3. Add the module to `default.nix`
4. Import and use in your home configuration

## Example Module Structure

```nix
{ config, lib, pkgs, ... }:

{
  options = {
    myModule = {
      enable = lib.mkEnableOption "my custom module";
      
      setting = lib.mkOption {
        type = lib.types.str;
        default = "default-value";
        description = "A custom setting";
      };
    };
  };

  config = lib.mkIf config.myModule.enable {
    # Your configuration here
  };
}
```

````