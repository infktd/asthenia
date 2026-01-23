{ pkgs, lib, inputs, ... }:

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

{
  # System-level module imports for niri and DMS
  # These provide NixOS integration and systemd service management
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.niri-flake.nixosModules.niri
  ];
  
  # Essential Wayland utilities required by niri compositor
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    libsecret
    cage
    gamescope
  ];

  # =============================================================================
  # WINDOW MANAGER PROGRAMS
  # =============================================================================
  programs = {
    # dconf required for GTK settings management
    dconf.enable = true;
    
    # Niri compositor - provides /bin/niri-session for login manager
    # CRITICAL: Do not remove - required for graphical login
    niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    
    # DMS (Dank Material Shell) - System service management
    # Creates systemd user service: dms.service
    # User-level settings configured via Home Manager (home/programs/dms/)
    dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
    };
  };

  # =============================================================================
  # POLKIT AUTHENTICATION
  # =============================================================================
  # Polkit agent required for privilege escalation prompts
  # (e.g., mounting drives, system settings, package management)
  security.polkit.enable = true;
  systemd = {
    user.services = {
      # Polkit GNOME agent - runs as user service
      # MUST start after graphical-session.target for proper session integration
      polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
      # Disable niri-flake's polkit agent since we're using polkit-gnome
      niri-flake-polkit.enable = false;
    };
  };

  # Bind DMS service to niri session
  # DMS will start when niri starts and stop when niri stops
  systemd.user.services.dms = {
    wantedBy = lib.mkForce [ "niri.service" ];
  };

  # =============================================================================
  # XDG DESKTOP PORTALS
  # =============================================================================
  # Portals provide desktop integration for sandboxed apps:
  # - File chooser dialogs
  # - Screen sharing / recording
  # - Notifications
  # System-level registration required for all users
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.common.default = [ "gtk" ];
  };

  # =============================================================================
  # LOGIN MANAGER (GREETD)
  # =============================================================================
  # greetd provides the login prompt and launches niri-session
  
  # TTY service config for login
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services = {
    # Bluetooth manager
    blueman.enable = true;

    # GTK theme config
    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    # User's credentials manager
    gnome.gnome-keyring.enable = true;

    # Greetd with TUI greeter
    # Launches niri-session on successful login
    # Session environment sources user's Home Manager profile
    greetd = {
      enable = true;
      settings = rec {
        tuigreet_session =
          let
            session = "${pkgs.niri-unstable}/bin/niri-session";
            tuigreet = "${lib.exe pkgs.tuigreet}";
          in
          {
            command = "${tuigreet} --time --remember --cmd ${session}";
            user = "greeter";
          };
        default_session = tuigreet_session;
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # Prerequisite for screensharing
      wireplumber.enable = true;
    };

    # Allows niri to run without root privileges
    seatd.enable = true;
  };
}
