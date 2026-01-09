# User-configurable variables for the asthenia NixOS configuration
# This file contains all parameters that users may want to customize
# Use the configuration TUI script to update these values interactively
{
  # === User Information ===
  user = {
    username = "infktd";
    fullName = "User";
    email = "user@example.com";
    homeDirectory = "/home/infktd";
  };

  # === System Configuration ===
  system = {
    hostname = "arasaka";
    architecture = "x86_64-linux";
  };

  # === Locale & Time ===
  locale = {
    timeZone = "America/Chicago";
    defaultLocale = "en_US.UTF-8";
  };

  # === Window Manager Selection ===
  # Options: "niri", "hyprland", null (for headless/no WM)
  windowManager = {
    selected = "niri";
    
    # Enable/disable specific WMs
    enable = {
      niri = true;
      hyprland = false;
    };
  };

  # === Hardware Features ===
  hardware = {
    # GPU configuration
    gpu = {
      nvidia = true;
      amd = false;
      intel = false;
    };
    
    # Audio
    audio = {
      enable = true;
      pipewire = true;
    };
    
    # Bluetooth
    bluetooth = {
      enable = true;
    };
    
    # Printing
    printing = {
      enable = false;
    };
  };

  # === Development Tools ===
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

  # === Applications ===
  applications = {
    # Browsers
    browsers = {
      chromium = true;
      firefox = false;
    };
    
    # Communication
    communication = {
      discord = true;
      signal = true;
      telegram = false;
    };
    
    # Media
    media = {
      vlc = true;
      mpv = false;
      spotify = false;
    };
    
    # File managers
    fileManager = {
      yazi = true;
      nautilus = false;
    };
    
    # Terminal
    terminal = {
      kitty = true;
      alacritty = false;
      wezterm = false;
    };
    
    # Other
    other = {
      obsidian = true;
    };
  };

  # === Gaming ===
  gaming = {
    enable = false;
    steam = false;
    lutris = false;
  };

  # === Secrets Management ===
  secrets = {
    enable = false;
    # Path to age key file
    ageKeyFile = "/home/infktd/.config/sops/age/keys.txt";
  };

  # === Network Configuration ===
  network = {
    networkManager = true;
    wireless = false;
  };

  # === Advanced Options ===
  advanced = {
    # Allow unfree packages
    allowUnfree = true;
    
    # Enable experimental features
    experimentalFeatures = true;
    
    # Auto-upgrade
    autoUpgrade = false;
    
    # Garbage collection
    autoGarbageCollect = true;
    garbageCollectDays = 7;
  };
}
