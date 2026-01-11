# =============================================================================
# USER SERVICES
# =============================================================================
# User-level systemd services and daemons
# These run in the user session (not system-wide)
#
# SYSTEM VS USER SERVICES:
# - System services (system/): Run as root, start at boot
# - User services (this file): Run as user, start at login
#
# CURRENT SERVICES:
# - gpg-agent: Manages GPG keys and provides SSH agent
#
# SERVICE MANAGEMENT:
# - Start: systemctl --user start <service>
# - Stop: systemctl --user stop <service>
# - Status: systemctl --user status <service>
# - Logs: journalctl --user -u <service>
#
# ADDING NEW SERVICES:
# Add to services = { } block below or create systemd.user.services entries
# Example: services.syncthing.enable = true;
# =============================================================================
{
  services = {
    # -------------------------------------------------------------------------
    # GPG AGENT
    # -------------------------------------------------------------------------
    # GnuPG agent for key management and SSH authentication
    #
    # FEATURES:
    # - Caches GPG key passphrases
    # - Provides SSH agent functionality (replaces ssh-agent)
    # - Enables GPG-based SSH keys
    #
    # USE CASES:
    # - Signing git commits: git config --global commit.gpgsign true
    # - SSH with GPG keys: ssh-add -L (shows GPG-based SSH keys)
    # - Encrypting files: gpg -e file.txt
    #
    # SSH SUPPORT:
    # - With enableSshSupport, GPG keys can authenticate SSH connections
    # - GPG keys exposed as SSH keys via $SSH_AUTH_SOCK
    # - Allows hardware keys (Yubikey) for SSH authentication
    #
    # ENVIRONMENT VARIABLES SET:
    # - SSH_AUTH_SOCK: Points to GPG agent socket
    # - GPG_TTY: Current terminal for passphrase prompts
    # -------------------------------------------------------------------------
    gpg-agent = {
      enable = true;
      
      # Use GPG agent as SSH agent
      # Allows GPG keys (including hardware keys) to be used for SSH
      enableSshSupport = true;
    };
    
    # -------------------------------------------------------------------------
    # ADDITIONAL USER SERVICES
    # -------------------------------------------------------------------------
    # Uncomment or add services as needed:
    #
    # File synchronization:
    # syncthing.enable = true;
    #
    # Email notification daemon:
    # mbsync.enable = true;
    #
    # Clipboard manager:
    # clipmenu.enable = true;
    #
    # For custom services, use:
    # systemd.user.services.<name> = { ... };
    # -------------------------------------------------------------------------
  };
}
