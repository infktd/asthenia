# NixOS Configuration Cheat Sheet

Quick reference for common operations with this configuration.

## 🔨 Build Commands

### Home Manager
```bash
# Build configuration
nix build .#homeConfigurations.default.activationPackage

# Activate (apply changes)
./result/activate

# Build and activate in one step
home-manager switch --flake .#default
```

### NixOS System
```bash
# Build and switch
sudo nixos-rebuild switch --flake .#default

# Build and test (doesn't set as default)
sudo nixos-rebuild test --flake .#default

# Build without applying
sudo nixos-rebuild build --flake .#default

# Build for a specific machine
sudo nixos-rebuild switch --flake .#mymachine
```

## 🔄 Update & Maintenance

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Show flake metadata
nix flake metadata

# Show flake outputs
nix flake show

# Garbage collection
nix-collect-garbage -d

# Clean old generations (system)
sudo nix-collect-garbage -d

# List generations
nix-env --list-generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## 🐛 Debugging

```bash
# Check flake for errors
nix flake check

# Build with detailed trace
nix build .#homeConfigurations.default.activationPackage --show-trace

# Check configuration
nixos-rebuild dry-build --flake .#default

# Rollback system
sudo nixos-rebuild switch --rollback

# Rollback home-manager
home-manager generations  # List generations
# Then use the activation script from a previous generation
```

## 📦 Package Management

```bash
# Search for packages
nix search nixpkgs <package-name>

# Try a package without installing
nix shell nixpkgs#<package-name>

# Run a package temporarily
nix run nixpkgs#<package-name>

# Show package info
nix eval nixpkgs#<package-name>.meta.description
```

## 📁 File Structure Quick Guide

### Adding a Program
1. Create `home/programs/myapp/default.nix`
2. Edit `home/shared/programs.nix` to import it
3. Rebuild Home Manager

### Adding a System Package
1. Edit `system/configuration.nix`
2. Add to `environment.systemPackages`
3. Rebuild NixOS

### Adding a User Package
1. Edit `home/shared/default.nix`
2. Add to `packages`
3. Rebuild Home Manager

### Creating a New Machine
1. `mkdir -p system/machine/mymachine`
2. Generate hardware config: `nixos-generate-config --show-hardware-config > system/machine/mymachine/hardware-configuration.nix`
3. Create `system/machine/mymachine/default.nix`
4. Add to `outputs/os.nix` hosts list
5. Build: `sudo nixos-rebuild switch --flake .#mymachine`

## 🔐 Secrets Management

```bash
# Create a secret
echo "secret-data" > home/secrets/mysecret.txt
chmod 600 home/secrets/mysecret.txt

# Use in configuration
# home.sessionVariables.SECRET = builtins.readFile ../secrets/mysecret.txt;

# Verify not tracked by git
git status  # Should not show secrets/
```

## 🎯 Configuration Profiles

### Home Manager Profiles
- `default` - Standard configuration
- `hidpi` - HiDPI displays
- `mutable` - Development with live-editing

```bash
# Use a specific profile
nix build .#homeConfigurations.hidpi.activationPackage
./result/activate
```

## 🧪 Testing Changes

```bash
# Test syntax without building
nix flake check

# Dry run (show what would change)
nixos-rebuild dry-build --flake .#default

# Test without making default
nixos-rebuild test --flake .#default

# Build in VM (for testing big changes)
nixos-rebuild build-vm --flake .#default
./result/bin/run-*-vm
```

## 📝 Git Operations

```bash
# Initial commit
git init
git add .
git commit -m "Initial NixOS configuration"

# Commit changes
git add .
git commit -m "Description of changes"

# Create a branch for experiments
git checkout -b experiment
# ... make changes ...
git checkout main  # Return to main branch
```

## 🔍 Inspection

```bash
# Show current system generation
readlink /nix/var/nix/profiles/system

# Show current home-manager generation
readlink ~/.local/state/nix/profiles/home-manager

# List all system generations
ls -l /nix/var/nix/profiles/system-*-link

# Show what packages are installed
nix-env -q

# Show store paths for a package
nix-store -q --references $(which <program>)

# Check disk usage
nix-store --gc --print-dead
nix path-info -rsSh $(nix-store -q --references /run/current-system)
```

## 🚨 Emergency Recovery

### Broken Configuration
```bash
# Boot into previous generation from GRUB menu
# Or rollback:
sudo nixos-rebuild switch --rollback
```

### Broken Home Manager
```bash
# Find previous generation
home-manager generations

# Activate previous generation
/nix/store/<hash>-home-manager-generation/activate
```

### Nuclear Option (Fresh Start)
```bash
# Remove all old generations
nix-collect-garbage -d
sudo nix-collect-garbage -d

# Rebuild from scratch
sudo nixos-rebuild switch --flake .#default
```

## 💡 Tips & Tricks

### Speed up builds
```bash
# Use binary cache
# Already configured in flake.nix

# Parallel builds (in configuration.nix)
nix.settings.max-jobs = 4;
nix.settings.cores = 4;
```

### Edit configs interactively
```bash
# Enable mutable dotfiles in your config
dotfiles.mutable = true;

# Then edit files directly and rebuild
```

### Quick package test
```bash
# Install temporarily
nix shell nixpkgs#htop

# Try different version
nix shell github:NixOS/nixpkgs/nixos-23.11#htop
```

## 📚 Common File Locations

- User packages: `home/shared/default.nix`
- System packages: `system/configuration.nix`
- Program configs: `home/programs/*/default.nix`
- Services: `home/services/*/default.nix`
- System services: `system/configuration.nix`
- Secrets: `home/secrets/`
- Machine configs: `system/machine/*/`

## 🔗 Useful Commands

```bash
# Open NixOS options search
xdg-open "https://search.nixos.org/options"

# Open packages search
xdg-open "https://search.nixos.org/packages"

# Open Home Manager options
xdg-open "https://nix-community.github.io/home-manager/options.html"

# Check configuration syntax
nix-instantiate --parse flake.nix

# Format Nix files
nixpkgs-fmt .
# or
alejandra .
```

## 🆘 Getting Help

- NixOS Manual: `man configuration.nix`
- Home Manager: `man home-configuration.nix`
- NixOS Discourse: https://discourse.nixos.org/
- NixOS Wiki: https://nixos.wiki/
- Matrix Chat: #nix:nixos.org

---

Keep this file handy for quick reference!
