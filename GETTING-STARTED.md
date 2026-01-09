# Getting Started with Your NixOS Configuration

This guide will help you get started with your new NixOS configuration structure.

## Step 1: Customize Basic Settings

### Update Username
Edit `home/shared/default.nix`:
```nix
let
  username = "yourusername";  # Change this to your actual username
```

### Update System Settings
Edit `system/configuration.nix`:
```nix
networking.hostName = "nixos";  # Change to your desired hostname

users.users.yourusername = {  # Match the username from above
  isNormalUser = true;
  description = "Your Name";
  # ...
};
```

### Set Your Timezone
Edit `system/configuration.nix`:
```nix
time.timeZone = "America/New_York";  # Change to your timezone
```

### Configure Git
Edit `home/shared/programs.nix`:
```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
};
```

## Step 2: Generate Hardware Configuration

If you're setting up a new machine, generate the hardware configuration:

```bash
sudo nixos-generate-config --show-hardware-config > system/machine/arasaka/hardware-configuration.nix
```

**Important:** Review this file and make sure the UUIDs match your actual partitions!

## Step 3: Initial Build

### Option A: Home Manager Only

If you just want to set up your user environment:

```bash
# Build the base configuration
nix build .#homeConfigurations.default.activationPackage

# Activate it
./result/activate

# Or build the full Niri setup
nix build .#homeConfigurations.niri.activationPackage
./result/activate
```

### Option B: Full NixOS System

If you're setting up the entire system:

```bash
sudo nixos-rebuild switch --flake .#arasaka
```

## Step 4: Add Your First Program

Let's add a terminal emulator as an example.

1. **Create the program directory:**
   ```bash
   mkdir -p home/programs/alacritty
   ```

2. **Create the config file** `home/programs/alacritty/alacritty.nix`:
   ```nix
   { pkgs, ... }:

   {
     programs.alacritty = {
       enable = true;
       settings = {
         font.size = 12;
         window.opacity = 0.9;
       };
     };
   }
   ```

3. **Import it in** `home/wm/niri/default.nix` (for niri):
   ```nix
   imports = [
     ../../shared
     ../../programs/alacritty/alacritty.nix
     # ... other imports
   ];
   ```
   
   Or in `home/shared/programs.nix` (for base config):
   ```nix
   { pkgs, ... }:

   {
     imports = [
       ../programs/alacritty/alacritty.nix
     ];

     programs = {
       # ... existing programs
     };
   }
   ```

4. **Rebuild:**
   ```bash
   # For base
   nix build .#homeConfigurations.default.activationPackage
   # Or for niri
   nix build .#homeConfigurations.niri.activationPackage
   
   ./result/activate
   ```

## Step 5: Create a Machine-Specific Configuration

For multiple machines, create separate configurations:

1. **Create a new machine directory:**
   ```bash
   mkdir -p system/machine/laptop
   ```

2. **Generate hardware config:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > system/machine/laptop/hardware-configuration.nix
   ```

3. **Create** `system/machine/laptop/default.nix`:
   ```nix
   { config, pkgs, inputs, ... }:

   {
     imports = [
       ./hardware-configuration.nix
       ../../configuration.nix
     ];

     networking.hostName = "my-laptop";
     
     # Laptop-specific settings
     services.tlp.enable = true;  # Power management
   }
   ```
   ```

4. **Add to outputs** in `outputs/os.nix`:
   ```nix
   hosts = [ "arasaka" "laptop" ];
   ```

5. **Build:**
   ```bash
   sudo nixos-rebuild switch --flake .#laptop
   ```

## Step 6: Manage Secrets

1. **Create a secret file** in `home/secrets/`:
   ```bash
   echo "my-secret-api-key" > home/secrets/api-key.txt
   chmod 600 home/secrets/api-key.txt
   ```

2. **Use it in your config:**
   ```nix
   { config, ... }:

   {
     home.sessionVariables = {
       API_KEY = builtins.readFile ../secrets/api-key.txt;
     };
   }
   ```

3. **Verify it's gitignored:**
   ```bash
   git status  # Should not show home/secrets/api-key.txt
   ```

## Next Steps

- **Explore programs:** Check out [Home Manager options](https://nix-community.github.io/home-manager/options.html)
- **Add system services:** Browse [NixOS options](https://search.nixos.org/options)
- **Create modules:** Organize related configuration into modules
- **Add overlays:** Customize or add packages in `home/overlays/`

## Tips

- **Test before switching:** Use `nixos-rebuild test` to test without making it default
- **Check syntax:** Run `nix flake check` to validate your configuration
- **Read the docs:** Each directory has a README with specific guidance
- **Start simple:** Don't try to configure everything at once

## Common Issues

### "File not found" errors
- Check that imports use correct relative paths
- Ensure all files exist in expected locations

### Permission denied
- Make sure you're using `sudo` for NixOS system commands
- Check file permissions on secrets (should be 600 or 400)

### Build fails
- Run with `--show-trace` for detailed error messages
- Check syntax with `nix flake check`
- Ensure all imports are valid

## Getting Help

- Check the README in each directory
- Search [NixOS Discourse](https://discourse.nixos.org/)
- Browse [NixOS Wiki](https://nixos.wiki/)
- Look at the [original inspiration](https://github.com/gvolpe/nix-config)

Happy configuring! 🚀
