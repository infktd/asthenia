# Agent Instructions: Separate NixOS and Home Manager Configurations

## Objective
Separate Home Manager from NixOS module integration to enable independent `home-manager switch` usage while maintaining niri and DMS functionality through a hybrid system/user configuration approach.

## Background
- Current setup: Home Manager integrated as NixOS module (managed via `nixos-rebuild`)
- Target: Standalone Home Manager (managed via `home-manager switch`)
- Critical constraint: niri and DMS require both system-level services AND user-level configs
- Past failure cause: Removing system services broke session management

## Implementation Steps

### Step 1: Add Documentation to system/configuration.nix

**File:** `/home/infktd/.config/asthenia/system/configuration.nix`

**Action:** Add comments at the top of the file (after the `let` block, before `{`) explaining the configuration philosophy.

**Insert this comment block:**

```nix
# =============================================================================
# SYSTEM CONFIGURATION
# =============================================================================
# This file manages system-wide NixOS settings. User-level configurations
# are managed separately via standalone Home Manager (home-manager switch).
#
# CONFIGURATION PHILOSOPHY:
# - System level: Core OS, services, hardware, system-wide programs
# - User level (Home Manager): Dotfiles, user applications, themes
#
# For niri/DMS: System provides session infrastructure (login, systemd services),
# user provides configuration files and appearance settings.
# =============================================================================
```

### Step 2: Remove Home Manager NixOS Module Integration

**File:** `/home/infktd/.config/asthenia/system/configuration.nix`

**Action 1:** Remove the Home Manager nixosModule import from the `imports` array.

Find this line:
```nix
imports = [
  inputs.home-manager.nixosModules.home-manager
];
```

Replace with:
```nix
imports = [
  # Home Manager is managed separately via standalone configuration.
  # Run: home-manager switch --flake .#niri
  # (Home Manager nixosModule integration removed to enable full feature set)
];
```

**Action 2:** Remove the entire `home-manager` configuration block.

Find this block (around lines 16-23):
```nix
home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  extraSpecialArgs = { inherit inputs; };
  backupFileExtension = "backup";
  users.infktd = import ../home/wm/niri;
};
```

Delete the entire block.

**Action 3:** Add a comment where the block was removed:

```nix
# =============================================================================
# HOME MANAGER (Standalone)
# =============================================================================
# Home Manager configurations are managed independently via:
#   home-manager switch --flake .#niri
#
# This separation provides:
# - Full access to all Home Manager options
# - Independent user config updates (no sudo required)
# - Per-user customization
#
# Home Manager configs located at:
#   home/wm/niri/        - Niri window manager user config
#   home/shared/         - Shared user config (all profiles)
#   home/programs/       - Individual program configurations
# =============================================================================
```

### Step 3: Document system/wm/niri.nix

**File:** `/home/infktd/.config/asthenia/system/wm/niri.nix`

**Action:** Add comprehensive documentation at the top of the file explaining system-level responsibilities.

**Insert after the first line (after `{ pkgs, lib, inputs, ... }:`) and before the opening `{`:**

```nix
# =============================================================================
# NIRI SYSTEM CONFIGURATION
# =============================================================================
# This file manages SYSTEM-LEVEL window manager infrastructure.
# User-level configs (dotfiles, appearance) are in home/wm/niri/
#
# WHY SYSTEM-LEVEL?
# - programs.niri provides niri-session binary (required by greetd login)
# - programs.dms-shell creates systemd user services
# - System user services must be declared here for proper session startup
# - XDG portals need system-level registration
#
# SESSION STARTUP FLOW:
# 1. greetd (login manager) launches niri-session
# 2. niri-session starts niri compositor
# 3. graphical-session.target is reached
# 4. User services start: polkit-agent, dms
# 5. User environment inherits sessionVariables from Home Manager
#
# WHAT BELONGS HERE (System Level):
# - programs.niri (provides niri-session binary)
# - programs.dms-shell (creates systemd services)
# - systemd.user.services (session-critical services)
# - XDG portal system registration
# - Login manager (greetd) configuration
#
# WHAT BELONGS IN HOME MANAGER (User Level):
# - Niri KDL config files (~/.config/niri/*.kdl)
# - DMS appearance settings (theme, colors)
# - Session variables (WAYLAND, NVIDIA env vars)
# - User-specific keybindings and layouts
# =============================================================================
```

**Action 2:** Add inline comments for each major section.

**After the `imports` array, add:**
```nix
  # System-level module imports for niri and DMS
  # These provide NixOS integration and systemd service management
```

**Before `environment.systemPackages`, add:**
```nix
  # Essential Wayland utilities required by niri compositor
```

**Before the `programs = {` block, add:**
```nix
  # =============================================================================
  # WINDOW MANAGER PROGRAMS
  # =============================================================================
```

**Before `programs.dconf.enable`, add:**
```nix
  # dconf required for GTK settings management
```

**Before `programs.niri`, add:**
```nix
  # Niri compositor - provides /bin/niri-session for login manager
  # CRITICAL: Do not remove - required for graphical login
```

**Before `programs.dms-shell`, add:**
```nix
  # DMS (Dank Material Shell) - System service management
  # Creates systemd user service: dms.service
  # User-level settings configured via Home Manager (home/programs/dms/)
```

**Before the `security.polkit.enable` line, add:**
```nix
  # =============================================================================
  # POLKIT AUTHENTICATION
  # =============================================================================
  # Polkit agent required for privilege escalation prompts
  # (e.g., mounting drives, system settings, package management)
```

**Before `systemd.user.services.polkit-gnome-authentication-agent-1`, add:**
```nix
  # Polkit GNOME agent - runs as user service
  # MUST start after graphical-session.target for proper session integration
```

**Before `niri-flake-polkit.enable = false`, add:**
```nix
    # Disable niri-flake's built-in polkit (we use polkit-gnome instead)
```

**Before `systemd.user.services.dms`, add:**
```nix
  # Bind DMS service to niri session
  # DMS will start when niri starts and stop when niri stops
```

**Before the `xdg.portal` block, add:**
```nix
  # =============================================================================
  # XDG DESKTOP PORTALS
  # =============================================================================
  # Portals provide desktop integration for sandboxed apps:
  # - File chooser dialogs
  # - Screen sharing / recording
  # - Notifications
  # System-level registration required for all users
```

**Before `programs.xwayland`, add:**
```nix
  # =============================================================================
  # X11 COMPATIBILITY
  # =============================================================================
  # Enable Xwayland for legacy X11 applications
```

**Before `hardware.graphics`, add:**
```nix
  # =============================================================================
  # GRAPHICS AND DISPLAY
  # =============================================================================
```

**Before `services.libinput`, add:**
```nix
  # =============================================================================
  # INPUT DEVICES
  # =============================================================================
```

**Before `services.displayManager.sessionPackages`, add:**
```nix
  # =============================================================================
  # LOGIN MANAGER (GREETD)
  # =============================================================================
  # greetd provides the login prompt and launches niri-session
```

**Before the final `services.greetd` block, add:**
```nix
  # Greetd with TUI greeter
  # Launches niri-session on successful login
  # Session environment sources user's Home Manager profile
```

### Step 4: Document home/wm/niri/default.nix

**File:** `/home/infktd/.config/asthenia/home/wm/niri/default.nix`

**Action:** Add documentation explaining user-level configuration.

**Insert after the `let` block and before the opening `{`:**

```nix
# =============================================================================
# NIRI USER CONFIGURATION (Home Manager)
# =============================================================================
# This file manages USER-LEVEL niri and desktop environment settings.
# System-level infrastructure is in system/wm/niri.nix
#
# WHAT BELONGS HERE (User Level):
# - Niri configuration files (KDL format in ./config/)
# - Session environment variables (Wayland, NVIDIA, performance)
# - User-specific packages (tools, fonts, audio controls)
# - Desktop appearance and behavior
#
# APPLIED VIA: home-manager switch --flake .#niri
# (NOT via nixos-rebuild - this is standalone Home Manager)
#
# RELATIONSHIP TO SYSTEM CONFIG:
# - System provides: niri-session binary, systemd services, login manager
# - User provides: config files, environment, appearance
# - Both work together: system starts session, user config customizes it
# =============================================================================
```

**Action 2:** Add inline comments for major sections.

**Before the `imports` array, add:**
```nix
  # Import shared user configuration (base programs, themes, services)
```

**Before `home.pointerCursor`, add:**
```nix
  # =============================================================================
  # DESKTOP APPEARANCE
  # =============================================================================
```

**Before `home.sessionVariables`, add:**
```nix
  # =============================================================================
  # SESSION ENVIRONMENT VARIABLES
  # =============================================================================
  # These variables are set in the user's graphical session
  # Applied when niri-session starts (after login via greetd)
```

**Before the Wayland variables, add:**
```nix
      # Wayland-specific settings
```

**Before the NVIDIA variables, add:**
```nix
      # NVIDIA + Wayland performance and compatibility
```

**Before the performance variables, add:**
```nix
      # Aggressive performance tuning for NVIDIA
```

**Before `fonts.fontconfig.enable`, add:**
```nix
  # =============================================================================
  # FONTS
  # =============================================================================
```

**Before `xdg.configFile."niri/config.kdl"`, add:**
```nix
  # =============================================================================
  # NIRI CONFIGURATION FILES
  # =============================================================================
  # Modular KDL config files for niri compositor
  # Main config imports the other modules
```

**Before the `xdg.configFile."electron-flags.conf"` line, add:**
```nix
  # Electron app optimization for Wayland
```

**Before the `xdg.portal` block, add:**
```nix
  # =============================================================================
  # XDG PORTALS (User Configuration)
  # =============================================================================
  # NOTE: System-level portal registration in system/wm/niri.nix
  # This configures portal preferences for this user
```

### Step 5: Remove Duplicate XDG Portal Config

**File:** `/home/infktd/.config/asthenia/home/wm/niri/default.nix`

**Action:** Remove or comment out the entire `xdg.portal` block (lines 88-101).

Replace the entire block with:

```nix
  # =============================================================================
  # XDG PORTALS
  # =============================================================================
  # Portal registration is managed at system level (system/wm/niri.nix)
  # User-level portal configuration removed to avoid conflicts
  # System configuration provides:
  # - xdg-desktop-portal-gtk
  # - xdg-desktop-portal-gnome
  # - Default portal assignments
  # =============================================================================
```

### Step 6: Create DMS Home Manager Module

**File:** `/home/infktd/.config/asthenia/home/programs/dms/dms.nix`

**Action:** Create new file with DMS user-level configuration.

**Create the file with this content:**

```nix
{ config, lib, inputs, ... }:

# =============================================================================
# DMS (Dank Material Shell) - Home Manager Configuration
# =============================================================================
# This configures USER-LEVEL DMS settings (appearance, behavior).
# System-level DMS service is managed in system/wm/niri.nix
#
# DUAL-LEVEL CONFIGURATION:
# - System (system/wm/niri.nix):
#   * programs.dms-shell with systemd enabled
#   * Creates and manages dms.service
#   * Binds service to niri session
#
# - User (this file):
#   * programs.dank-material-shell (homeModule)
#   * Theme, colors, appearance settings
#   * User-specific behavior preferences
#
# This split allows:
# - System manages service lifecycle (start/stop/restart)
# - User manages look and feel (no root required)
# =============================================================================

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
    settings = {
      theme = "dark";
      dynamicTheming = true;
    };
  };
}
```

### Step 7: Import DMS in Home Manager

**File:** `/home/infktd/.config/asthenia/home/shared/programs.nix`

**Action:** Add DMS import to the imports array.

Find the `imports` array at the top of the file and add:

```nix
  imports = [
    ../programs/git/git.nix
    ../programs/alacritty/alacritty.nix
    ../programs/vscode/vscode.nix
    ../programs/nvf/nvf.nix
    ../programs/chrome/chrome.nix
    ../programs/discord/discord.nix
    ../programs/obsidian/obsidian.nix
    ../programs/yazi/yazi.nix
    ../programs/fuzzle/fuzzle.nix
    ../programs/zsh/zsh.nix
    ../programs/dms/dms.nix  # DMS user-level configuration
  ];
```

### Step 8: Update Zsh Configuration

**File:** `/home/infktd/.config/asthenia/home/programs/zsh/zsh.nix`

**Action:** Ensure Zsh config uses Home Manager-specific options (autosuggestions, syntax highlighting).

**Replace the entire file content with:**

```nix
{ pkgs, ... }:

# =============================================================================
# ZSH CONFIGURATION (Home Manager)
# =============================================================================
# Full-featured Zsh configuration with Home Manager-specific options.
# These options are NOT available when Home Manager is used as NixOS module.
#
# Features enabled:
# - Oh My Zsh (plugin/theme framework)
# - Autosuggestions (suggest commands as you type)
# - Syntax highlighting (color-code commands)
# - Starship prompt (modern, fast cross-shell prompt)
# =============================================================================

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;  # Home Manager specific
    syntaxHighlighting.enable = true;  # Home Manager specific
    
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" ];
    };
    
    # Initialize Starship prompt
    initExtra = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      # Starship configuration
      # See: https://starship.rs/config/
    };
  };
}
```

### Step 9: Create Configuration Guide

**File:** `/home/infktd/.config/asthenia/CONFIGURATION-GUIDE.md`

**Action:** Create comprehensive documentation.

**Create the file with this content:**

```markdown
# Configuration Guide: System vs User Split

## Overview

This NixOS configuration uses a **hybrid approach** where:
- **NixOS** manages system-level infrastructure
- **Home Manager** (standalone) manages user-level configuration

## Why the Split?

### Integrated Home Manager (What We Left Behind)
- Home Manager as NixOS module: `home-manager.users.infktd = ...`
- Applied via: `sudo nixos-rebuild switch`
- **Limitation**: Restricted to basic Home Manager options
- **Problem**: Advanced features (zsh plugins, themes) unavailable

### Standalone Home Manager (Current Setup)
- Home Manager independent: `homeConfigurations.niri`
- Applied via: `home-manager switch --flake .#niri`
- **Benefit**: Full access to all Home Manager options
- **Benefit**: Update user config without root/system rebuild

## Configuration Locations

### System Configuration (sudo nixos-rebuild switch)

**File:** `system/configuration.nix`
- User accounts and shell assignment
- Bootloader, networking, timezone
- System packages (core utilities)
- Hardware configuration
- Nix settings (flakes, gc, trusted users)

**File:** `system/wm/niri.nix`
- Window manager infrastructure
- Login manager (greetd)
- System-level window manager services
- XDG portals (system registration)
- Graphics and input configuration

**What Belongs at System Level:**
- Services required for login/session startup
- Hardware and driver configuration
- System-wide programs (available to all users)
- Security and authentication infrastructure

### User Configuration (home-manager switch)

**Directory:** `home/wm/niri/`
- Niri compositor user config (KDL files)
- Session environment variables
- User-specific packages and tools
- Desktop appearance preferences

**Directory:** `home/shared/`
- Base configuration for all profiles
- Common programs and utilities
- Shared themes and settings

**Directory:** `home/programs/`
- Individual program configurations
- Git, Alacritty, VSCode, Neovim, etc.
- Shell configuration (zsh + starship)

**What Belongs at User Level:**
- Dotfiles and configuration files
- Application settings and themes
- User scripts and tools
- Personal preferences

## Special Case: Niri + DMS

Niri (window manager) and DMS (desktop shell) require **both** system and user configuration.

### System Level (system/wm/niri.nix)

**Why System Level?**
1. **Login Integration**: greetd needs `niri-session` binary
2. **Service Management**: systemd user services must be declared at system level
3. **Session Infrastructure**: graphical-session.target provided by niri-flake

**What's Configured:**
```nix
programs.niri = {
  enable = true;  # Provides niri-session for login
  package = pkgs.niri-unstable;
};

programs.dms-shell = {
  enable = true;
  systemd.enable = true;  # Creates dms.service
  # ... system-level features
};

systemd.user.services = {
  polkit-gnome-authentication-agent-1 = { ... };  # Auth prompts
  dms = { wantedBy = [ "niri.service" ]; };  # Bind DMS to niri
};
```

### User Level (home/wm/niri/ and home/programs/dms/)

**What's Configured:**
```nix
# Niri config files
xdg.configFile."niri/config.kdl".source = ./config/config.kdl;

# Session variables
home.sessionVariables = {
  NIXOS_OZONE_WL = 1;
  MOZ_ENABLE_WAYLAND = 1;
  # ... NVIDIA/Wayland settings
};

# DMS appearance
programs.dank-material-shell = {
  enable = true;
  settings = {
    theme = "dark";
    dynamicTheming = true;
  };
};
```

## Session Startup Flow

Understanding the boot → session flow helps explain the split:

```
1. System Boot
   ↓
2. greetd (system service)
   ↓
3. User login → greetd launches niri-session
   ↓
4. niri-session starts niri compositor
   ↓
5. graphical-session.target reached
   ↓
6. User services start:
   - polkit-gnome-authentication-agent-1
   - dms (bound to niri.service)
   ↓
7. User environment loaded:
   - Home Manager profile sourced
   - sessionVariables applied
   - Config files (~/.config) available
   ↓
8. Desktop ready
```

**Critical Points:**
- Steps 1-5: Require system-level configuration
- Steps 6-7: Use both system and user config
- Step 8: Fully user-level

## Workflow

### Making Changes

**System Changes** (requires root):
```bash
# Edit system config
vim system/configuration.nix
vim system/wm/niri.nix

# Apply
sudo nixos-rebuild switch --flake .#arasaka
```

**User Changes** (no root needed):
```bash
# Edit user config
vim home/programs/zsh/zsh.nix
vim home/wm/niri/default.nix

# Apply
home-manager switch --flake .#niri
```

**Both**:
```bash
sudo nixos-rebuild switch --flake .#arasaka
home-manager switch --flake .#niri
```

### Using the asthenia Script

```bash
# System only
asthenia --switch nixos

# User only
asthenia --switch hm niri

# Both
asthenia --switch all
```

## Troubleshooting

### Niri Won't Start After Login

**Check:**
1. Is `programs.niri.enable = true` in system config?
2. Does `niri-session` binary exist? (`which niri-session`)
3. Are system user services defined? (`systemctl --user list-units`)

**Fix:**
- Ensure `system/wm/niri.nix` has `programs.niri` enabled
- Run `sudo nixos-rebuild switch --flake .#arasaka`

### DMS Not Loading

**Check:**
1. Is `programs.dms-shell` in system config with systemd enabled?
2. Is DMS service running? (`systemctl --user status dms`)
3. Is service bound to niri? (`systemctl --user show dms | grep WantedBy`)

**Fix:**
- Verify system config has DMS service declaration
- Verify user config has DMS settings
- Check service binding: `wantedBy = [ "niri.service" ]`

### Environment Variables Not Set

**Check:**
```bash
echo $NIXOS_OZONE_WL
echo $MOZ_ENABLE_WAYLAND
```

**If empty:**
1. Are variables in `home.sessionVariables`? (home/wm/niri/default.nix)
2. Did you run `home-manager switch`?
3. Did you log out and back in?

**Fix:**
- Ensure variables in user config
- Run `home-manager switch --flake .#niri`
- Log out, log back in

### Home Manager Command Not Found

**Install:**
```nix
# Add to home/shared/default.nix or home/shared/programs.nix
programs.home-manager.enable = true;
```

Then run: `nix run home-manager/master -- switch --flake .#niri`

After first run, `home-manager` command will be available.

### Changes Not Applied After home-manager switch

**Check:**
1. Did Home Manager succeed? (check output for errors)
2. Are you in the right profile? (`home-manager --version`)
3. Did you reload the application?

**Reload required for:**
- Shell: `exec zsh` or log out/in
- Desktop: Log out/in
- Applications: Restart them

## Common Patterns

### Adding a New Program

1. Create config file: `home/programs/myapp/myapp.nix`
2. Add to imports: `home/shared/programs.nix`
3. Apply: `home-manager switch --flake .#niri`

### Changing System Service

1. Edit: `system/configuration.nix` or `system/wm/niri.nix`
2. Apply: `sudo nixos-rebuild switch --flake .#arasaka`
3. May need to reboot for some services

### Changing User Appearance

1. Edit: `home/themes/` or program config
2. Apply: `home-manager switch --flake .#niri`
3. Reload app or log out/in

## Best Practices

### Comments
- Add comments explaining WHY, not just WHAT
- Document system/user split decisions
- Note dependencies and critical services

### Testing
- Test system changes in VM first (if possible)
- Keep backup of working configuration
- Use git branches for major refactors

### Organization
- One program = one file in `home/programs/`
- Group related system services in dedicated files
- Use `shared/` for truly common config

### Separation Guidelines

**System level if:**
- Required for boot/login
- Creates systemd services
- Hardware/driver related
- Affects all users
- Requires root privileges

**User level if:**
- Dotfile or config file
- Application settings
- Personal preferences
- Can change without root
- User-specific customization

## Architecture Diagram

```
flake.nix
├── nixosConfigurations.arasaka
│   └── system/
│       ├── configuration.nix (users, system settings)
│       ├── wm/niri.nix (niri/dms system services)
│       ├── fonts/
│       └── machine/arasaka/ (hardware config)
│
└── homeConfigurations.niri
    └── home/
        ├── wm/niri/ (niri user config)
        ├── shared/ (base config)
        │   ├── default.nix
        │   ├── programs.nix
        │   └── services.nix
        ├── programs/ (per-app configs)
        │   ├── zsh/
        │   ├── alacritty/
        │   ├── dms/
        │   └── ...
        └── themes/
```

## Further Reading

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Niri Wiki](https://github.com/YaLTeR/niri/wiki)
- Project Documentation:
  - `README.md` - Quick start
  - `STRUCTURE.md` - File organization
  - `GETTING-STARTED.md` - Initial setup

## Summary

The separation provides:
- ✅ Full Home Manager feature set
- ✅ User config updates without root
- ✅ Proper niri/DMS integration
- ✅ Clear system/user boundaries
- ✅ Maintainable, documented configuration

Key principle: **System provides infrastructure, user provides customization.**
```

## Testing Procedure

After all changes are complete, follow this testing procedure:

### Phase 1: Validate Syntax

```bash
# Check for Nix syntax errors
nix flake check

# Build system config (don't apply yet)
nixos-rebuild build --flake .#arasaka

# Build home config (don't apply yet)
nix build .#homeConfigurations.niri.activationPackage
```

### Phase 2: Apply System Changes

```bash
# Apply system configuration
sudo nixos-rebuild switch --flake .#arasaka

# Verify no errors in output
# System should rebuild successfully
```

### Phase 3: Apply User Changes

```bash
# First time: Install home-manager command
nix run home-manager/master -- switch --flake .#niri

# Subsequent times:
home-manager switch --flake .#niri

# Verify no errors in output
```

### Phase 4: Test Session

```bash
# Log out completely
# Log back in via greetd → niri

# After login, verify:

# 1. Niri started successfully
echo "Niri running: $(pgrep -x niri && echo YES || echo NO)"

# 2. DMS loaded
systemctl --user status dms

# 3. Environment variables set
echo "NIXOS_OZONE_WL: $NIXOS_OZONE_WL"
echo "MOZ_ENABLE_WAYLAND: $MOZ_ENABLE_WAYLAND"

# 4. Polkit agent running
systemctl --user status polkit-gnome-authentication-agent-1

# 5. XDG portals available
ls /run/user/$UID/xdg-desktop-portal/

# 6. Test applications
# Open Alacritty, Chrome, etc.
```

### Phase 5: Validation Checklist

- [ ] System builds without errors
- [ ] Home Manager builds without errors
- [ ] Can log in via greetd
- [ ] Niri compositor starts
- [ ] DMS appears and is functional
- [ ] Polkit prompts work (test with: `systemctl restart test`)
- [ ] Environment variables are set
- [ ] Applications launch normally
- [ ] File chooser works (XDG portals)
- [ ] Zsh with Oh My Zsh and Starship works
- [ ] Alacritty uses Oxocarbon theme

## Important Notes

1. **Backup First**: Ensure you have a backup or can boot into a previous generation if something breaks.

2. **Order Matters**: Apply system changes BEFORE home manager changes (system provides infrastructure that user config depends on).

3. **Session Reload**: Most changes require logging out and back in to take effect.

4. **Service Dependencies**: The system user services (polkit, dms) must exist before Home Manager tries to configure them.

5. **Git State**: Consider committing working config before starting, or create a branch.

## Success Criteria

Configuration separation is successful when:

1. ✅ `sudo nixos-rebuild switch --flake .#arasaka` completes without errors
2. ✅ `home-manager switch --flake .#niri` completes without errors  
3. ✅ Can log in and start niri session
4. ✅ DMS loads and displays correctly
5. ✅ All applications work as before
6. ✅ Environment variables are properly set
7. ✅ Can modify user config without touching system config

## Rollback Procedure

If something breaks:

**System Rollback:**
```bash
# List generations
sudo nixos-rebuild list-generations

# Boot into previous generation
# (Select in boot menu, or:)
sudo nixos-rebuild switch --rollback
```

**Home Manager Rollback:**
```bash
# List generations
home-manager generations

# Rollback
home-manager --rollback
```

## Additional Changes to Consider

These are optional but recommended:

1. **Update flake.nix**: Add comments explaining the homeConfigurations outputs
2. **Update README.md**: Document the new workflow (system vs user rebuilds)
3. **Update GETTING-STARTED.md**: Mention home-manager switch requirement
4. **.gitignore**: Ensure result symlinks are ignored

## Questions to Verify With User

Before implementing, confirm:

1. Is there a git backup or can you easily rollback?
2. Are you okay with having to run two commands (system + home) for updates?
3. Do you have access to TTY/console login if graphical session breaks?
4. Is there a working previous generation you can boot into?

## End of Instructions

These instructions should be sufficient for a coding agent to implement the complete separation. All file paths, code blocks, and testing procedures are provided.
