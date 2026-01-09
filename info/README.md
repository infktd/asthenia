# Project Info (Consolidated)

This single document consolidates the README files from the repository for quick reference.

**Sections:**
- Home (Home Manager layout and usage)
- Programs (per-app modules)
- Modules (reusable home modules)
- Themes (GTK and color schemes)
- Window Managers (user and system-level notes)
- Outputs (how the flake exposes builds)
- Lib (overlays and helper functions)
- System (global system config and machine layout)
- Fonts & Misc (custom fonts, misc files)
- Secrets (where to store sensitive files)

---

## Home

The `home/` directory contains Home Manager configuration for user environments. Key subfolders:
- `shared/` — base config imported by all profiles (`shared/default.nix`)
- `programs/` — per-application modules (each app in its own folder)
- `modules/` — reusable home manager modules (e.g. `dotfiles.nix`, `hidpi.nix`)
- `themes/` — color schemes and GTK theme settings
- `wm/` — user-level window manager configs (e.g. `niri`)
- `secrets/` — sensitive files (keep out of git)

Build the Home Manager activation package from the repo root:

```bash
nix build .#homeConfigurations.default.activationPackage
./result/activate   # do not run locally if you don't want to change this host
```

---

## Programs

Per-app config lives under `home/programs/<app>/`. Example modules expose `programs.<app>` options that Home Manager understands and will install the package automatically; you typically do not add such packages to the `packages = with pkgs; [...]` list in `home/shared/default.nix`.

To add a program in gvolpe's style:
1. Create `home/programs/firefox/default.nix` (or `firefox.nix`).
2. Import the folder in your top-level home `imports` (e.g. in `home/shared/default.nix`).

---

## Modules

Custom home modules live in `home/modules/` and must export a proper Home Manager module (an attrset or function with `{ config, lib, pkgs, ... }:`). If a module is malformed it will break evaluation (see the Home Manager build errors).

Example module shape:

```nix
{ config, lib, pkgs, ... }:

{
  options = { myModule = { enable = lib.mkEnableOption "..."; }; };
  config = lib.mkIf config.myModule.enable { /* config */ };
}
```

---

## Themes

`home/themes/` holds color schemes and GTK settings. The common pattern is to export a `colors.nix` with Base16 schemes and a `default.nix` that configures GTK/icon themes.

---

## Window Managers

There are both user-level (`home/wm/`) and system-level (`system/wm/`) configs. User configs set environment and keybindings; system configs enable services like `greetd`, `pipewire`, or Seat management.

To use a WM per-machine, import the system WM module in `system/machine/<host>/default.nix` and enable the corresponding home profile that provides the user session.

---

## Outputs

`outputs/hm.nix` and `outputs/os.nix` define the flake outputs for Home Manager and NixOS system builds. Use `nix flake show .` to inspect available outputs and profiles.

Build examples:

```bash
# Home
nix build .#homeConfigurations.default.activationPackage

# System (on the target machine)
sudo nixos-rebuild switch --flake .#hostname
```

---

## Lib & Overlays

`lib/` contains helper expressions and `overlays.nix` that inject custom overlays into `pkgs`. Add third-party overlays (like niri) there so packages become available to both home and system configurations.

---

## System

`system/configuration.nix` is the global baseline for all machines. Machine-specific overrides live under `system/machine/<hostname>/` (each should import its own `hardware-configuration.nix`).

---

## Fonts & Misc

Custom font derivations live in `system/fonts/`. Misc files such as `system/misc/groot.txt` are referenced from `configuration.nix`.

---

## Secrets

Keep secrets in `home/secrets/`. Use encryption (age, sops-nix) if you need to store secrets in the repo. Never commit plaintext secrets.

---

If you want these sections expanded into separate files again later, I can split them back out. This consolidated doc will be the single `info/README.md` going forward.
