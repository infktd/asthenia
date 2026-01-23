# Overlays in Asthenia

## Overview

Overlays modify the nixpkgs package set. This flake uses three overlays
applied in order:

1. `libOverlay` - Extends `pkgs.lib` with custom functions
2. `overlays` - Adds builder functions (`mkHome`, `mkNixos`)
3. `niri-flake.overlays.niri` - Adds `pkgs.niri-unstable`

## How Overlays Work

```nix
# Overlay signature
overlay = final: prev: { ... };
```

- `final` (or `f`): The final package set after ALL overlays applied
- `prev` (or `p`): The package set BEFORE this overlay

Use `prev` to reference existing packages. Use `final` for cross-references
to packages defined in other overlays.

## Adding Custom Lib Functions

Edit `lib/default.nix`:

```nix
{ lib }:
{
  # Your function here
  myFunc = arg: lib.someExisting arg;
}
```

Then export in `lib/overlays.nix`:

```nix
lib = (p.lib.extend (_: _: {
  inherit (libx) exe myFunc;  # Add myFunc here
})).extend libVersionOverlay;
```

Usage: `lib.myFunc` anywhere in the configuration.

## Adding New Packages via Overlay

Create a new overlay in `lib/overlays.nix`:

```nix
let
  myPackageOverlay = f: p: {
    myPackage = p.callPackage ../packages/my-package.nix { };
  };
in
[
  libOverlay
  overlays
  myPackageOverlay  # Add to the list
  inputs.niri-flake.overlays.niri
]
```

## Using External Flake Overlays

Add the overlay to the list:

```nix
[
  libOverlay
  overlays
  inputs.niri-flake.overlays.niri
  inputs.some-flake.overlays.default  # External overlay
]
```

## Builder Functions

Builders create configurations with consistent interfaces:

```nix
# Home Manager configurations
pkgs.builders.mkHome {
  extraHomeConfig = { };  # Optional: extra modules for all profiles
}

# NixOS system configurations
pkgs.builders.mkNixos {
  extraSystemConfig = { };  # Optional: extra modules for all systems
}
```

## Adding a New Profile/Machine

### New Home Manager Profile

Edit `outputs/hm.nix`, add to profiles list:

```nix
profiles = [ "default" "niri" "myprofile" ];
```

Create `home/wm/myprofile/default.nix` with the profile config.

### New NixOS Machine

Edit `outputs/os.nix`, add to hosts list:

```nix
hosts = [ "arasaka" "mymachine" ];
```

Create `system/machine/mymachine/` with:

- `default.nix` - Machine config
- `hardware-configuration.nix` - Run `nixos-generate-config`
