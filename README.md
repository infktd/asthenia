# Asthenia

NixOS + nix-darwin + Home Manager configuration for Linux (`arasaka`) and macOS (`esoteric`).

## How It Works

The config is split into two independent layers that update separately:

```
SYSTEM LAYER (requires sudo)          USER LAYER (no sudo)
├── NixOS    → nixos-rebuild switch    ├── home-manager switch
└── Darwin   → darwin-rebuild switch   └── (dotfiles, programs, secrets)
```

**Why separate layers?** You can iterate on your shell, editor, and theme config instantly without touching the kernel or system services. No sudo, no reboot.

The system layer manages hardware, services, and boot. The user layer manages everything you interact with day-to-day: programs, dotfiles, secrets, and theming. Both are declarative and reproducible from this single repo.

## Structure

```
flake.nix                 Machines and profiles defined inline
                          Overlays, package sets, and config builders

nixos/
  base.nix                All shared NixOS config (boot, nix, networking,
                          audio, packages, containers, users, sops)
  desktop.nix             Shared desktop services (greetd, bluetooth,
                          pipewire, polkit, XDG portals)
  niri.nix                Niri compositor + DMS shell (imports desktop.nix)
  hyprland.nix            Hyprland compositor (imports desktop.nix)
  nvidia.nix              NVIDIA proprietary driver for Wayland
  gaming.nix              Steam + GameMode

darwin.nix                All macOS config (nix, users, system defaults,
                          homebrew, Spotlight aliases)

home/
  default.nix             Entry point: imports shared + programs
  shared.nix              Identity, packages, secrets (sops-nix),
                          GPG agent, GTK themes
  programs/
    default.nix           Alacritty, git, bat, fzf, vscode, etc.
    shell.nix             Zsh + Starship prompt
    zellij.nix            Terminal multiplexer + layouts
    crush.nix             Local LLM TUI (Ollama)
    fuzzel.nix            Wayland app launcher
    waybar.nix            Status bar (Hyprland)
    mako.nix              Notifications (Hyprland)
    hyprlock.nix          Lock screen (Hyprland)
    hypridle.nix          Idle daemon (Hyprland)
    hyprpaper.nix         Wallpaper (Hyprland)
  desktop/
    wayland.nix           Shared Wayland/NVIDIA env vars, fonts, cursor
    niri/                 Niri KDL config files
    hyprland.nix          Hyprland WM settings + keybindings
    aerospace/            macOS tiling WM config
  scripts/
    asthenia.nix          Rebuild helper script

machines/arasaka/
  hardware-configuration.nix   Generated hardware config

secrets/
  secrets.yaml            Encrypted SSH key, GPG key, GitHub token
.sops.yaml                Age public key for encryption
```

### Why This Layout

**Feature-centric, not layer-centric.** Instead of scattering Niri config across `system/wm/niri.nix`, `home/wm/niri/default.nix`, and `home/programs/dms/dms.nix`, the NixOS side lives in `nixos/niri.nix` and the user side in `home/desktop/niri/`. Related config is close together.

**Shared desktop base.** `nixos/desktop.nix` holds everything common between Niri and Hyprland (greetd, bluetooth, polkit, pipewire, etc.). The WM-specific files only add what's unique. Same idea on the user side with `home/desktop/wayland.nix`.

**Flat programs.** Each program is one file, not a directory. Simple programs (bat, fzf, vscode, yazi) are inlined in `programs/default.nix`. Only programs with substantial config get their own file.

**Profiles live in flake.nix.** A profile is just a list of imports — no reason for a separate file. The flake directly says `niri = mkHome { modules = [ ./home ./home/desktop/niri ]; }`.

**Single-file darwin.** One machine, one file. No need to split 80 lines across 5 files.

## Quick Start

### New NixOS Machine

```bash
git clone git@github.com:infktd/asthenia.git ~/.config/asthenia
cd ~/.config/asthenia

# Set up secrets (see Secrets section below)
mkdir -p ~/.config/sops/age
# paste age private key into ~/.config/sops/age/keys.txt

# System
sudo nixos-rebuild switch --flake .#arasaka

# User
home-manager switch --flake .#niri
```

### New macOS Machine

```bash
git clone git@github.com:infktd/asthenia.git ~/.config/asthenia
cd ~/.config/asthenia

# Set up secrets
mkdir -p ~/.config/sops/age
# paste age private key into ~/.config/sops/age/keys.txt

# System
darwin-rebuild switch --flake .#esoteric

# User (run twice on first setup — sops-nix launchd PATH bug)
home-manager switch --flake .#aerospace
home-manager switch --flake .#aerospace
```

### Day-to-Day

```bash
# Rebuild helper (auto-detects platform and profile)
asthenia --switch hm            # User config only
asthenia --switch system        # System config only
asthenia --switch all           # Both
asthenia --update --switch all  # Update inputs first

# Or manually
home-manager switch --flake .#niri
sudo nixos-rebuild switch --flake .#arasaka
```

## Profiles

| Profile | Platform | What it includes |
|---------|----------|------------------|
| `default` | Linux | CLI tools, shell, git, secrets — no desktop |
| `niri` | Linux | Above + Niri WM, DMS shell, Wayland env |
| `hyprland` | Linux | Above + Hyprland WM, waybar, mako, hyprlock |
| `default-darwin` | macOS | CLI tools, shell, git, secrets — no WM |
| `aerospace` | macOS | Above + Aerospace tiling WM |

Switch between them with `home-manager switch --flake .#<profile>`.

Switching WMs on the system side requires changing which module flake.nix imports for the machine (e.g. `./nixos/niri.nix` vs `./nixos/hyprland.nix`) and rebuilding with `nixos-rebuild switch`.

## Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using age encryption. The encrypted file (`secrets/secrets.yaml`) is safe to commit. Decryption happens at activation time using your age private key.

### What's Managed

| Secret | Decrypted to | Purpose |
|--------|-------------|---------|
| SSH private key | `~/.ssh/id_ed25519` | Git, server access |
| GPG private key | GPG keyring | Commit signing |
| GitHub token | `gh` CLI auth | GitHub API |
| Tailscale auth key | `/run/secrets/tailscale_auth_key` | VPN (system-level) |

### Setup

1. Get the age private key from your password manager
2. Place it at `~/.config/sops/age/keys.txt`
3. Run `home-manager switch` — secrets decrypt automatically

### Forking This Repo

Generate your own age keypair and re-encrypt:

```bash
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # copy public key

# Update .sops.yaml with your public key, then:
sops secrets/secrets.yaml  # creates new encrypted secrets
```

### Adding a Secret

```bash
sops secrets/secrets.yaml  # edit decrypted, auto re-encrypts on save
```

Then reference it in `home/shared.nix`:

```nix
sops.secrets.my_secret = { path = "${homeDirectory}/.config/app/token"; mode = "0600"; };
```

## Adding a New Machine

### NixOS

1. Generate hardware config:
   ```bash
   nixos-generate-config --show-hardware-config > machines/new-host/hardware-configuration.nix
   ```

2. Add to `flake.nix`:
   ```nix
   nixosConfigurations.new-host = nixpkgs.lib.nixosSystem {
     # ...
     modules = [
       ./machines/new-host/hardware-configuration.nix
       ./nixos/base.nix
       # pick your desktop: ./nixos/niri.nix or ./nixos/hyprland.nix
       { networking.hostName = "new-host"; }
     ];
   };
   ```

### macOS

Add a new `darwinConfigurations` entry in `flake.nix` pointing at `./darwin.nix` with your hostname.

## Adding a Program

**Simple** (one-liner): add to `programs = { ... }` in `home/programs/default.nix`.

**Complex** (needs config): create `home/programs/my-program.nix` and add it to the imports in `home/programs/default.nix`.

## Troubleshooting

**`home-manager` not found**: `nix run nixpkgs#home-manager -- switch --flake .#niri`

**NVIDIA issues on Wayland**: check `echo $GBM_BACKEND` (should be `nvidia-drm`) and `lsmod | grep nvidia`.

**Niri not starting**: `systemctl status greetd` and `journalctl --user -u niri -e`.

**Secrets not decrypting**: verify `~/.config/sops/age/keys.txt` exists and has the correct private key.

## Links

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [Niri](https://github.com/YaLTeR/niri)
- [Dendritic Pattern](https://github.com/mightyiam/dendritic) (inspiration for this layout)
