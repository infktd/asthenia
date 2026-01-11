# =============================================================================
# GIT CONFIGURATION
# =============================================================================
# Version control configuration for git
#
# CONFIGURATION AREAS:
# - User identity (name and email)
# - Commit settings
# - Aliases and shortcuts
# - Diff and merge tools
#
# CURRENT SETUP:
# - Basic user identity configuration
# - Ready for expansion with aliases and tools
#
# COMMON ADDITIONS:
# - Commit signing: programs.git.signing.signByDefault = true;
# - Aliases: programs.git.aliases = { co = "checkout"; };
# - Delta diff: programs.git.delta.enable = true;
# - Git LFS: programs.git.lfs.enable = true;
# =============================================================================
{ lib, pkgs, ... }:

{
  programs.git = {
    # Enable git with Home Manager management
    enable = true;

    # Settings become entries in ~/.gitconfig
    settings = {
      # -----------------------------------------------------------------------
      # USER IDENTITY
      # -----------------------------------------------------------------------
      # Used for commit authorship
      # IMPORTANT: Change these to your own name and email
      user = {
        name = "infktd";
        # Using GitHub no-reply email for privacy
        # Format: <id>+<username>@users.noreply.github.com
        email = "25016104+infktd@users.noreply.github.com";
      };
      
      # -----------------------------------------------------------------------
      # ADDITIONAL CONFIGURATION IDEAS
      # -----------------------------------------------------------------------
      # Uncomment or add as needed:
      #
      # Default branch name:
      # init.defaultBranch = "main";
      #
      # Rebase by default on pull:
      # pull.rebase = true;
      #
      # Auto-correct mistyped commands:
      # help.autocorrect = 1;
      #
      # Better diff algorithm:
      # diff.algorithm = "histogram";
      #
      # Colorize output:
      # color.ui = "auto";
      # -----------------------------------------------------------------------
    };
    
    # -------------------------------------------------------------------------
    # GIT ALIASES
    # -------------------------------------------------------------------------
    # Uncomment to add convenient shortcuts:
    # aliases = {
    #   co = "checkout";
    #   br = "branch";
    #   ci = "commit";
    #   st = "status";
    #   unstage = "reset HEAD --";
    #   last = "log -1 HEAD";
    #   graph = "log --graph --oneline --decorate";
    # };
    
    # -------------------------------------------------------------------------
    # DELTA DIFF VIEWER
    # -------------------------------------------------------------------------
    # Syntax-highlighted diff with line numbers
    # delta.enable = true;
    # delta.options = {
    #   navigate = true;
    #   line-numbers = true;
    #   syntax-theme = "Dracula";
    # };
    
    # -------------------------------------------------------------------------
    # COMMIT SIGNING
    # -------------------------------------------------------------------------
    # Sign commits with GPG key
    # Requires GPG key setup and gpg-agent service
    # signing = {
    #   signByDefault = true;
    #   key = "<your-gpg-key-id>";
    # };
    
    # -------------------------------------------------------------------------
    # GIT LFS
    # -------------------------------------------------------------------------
    # Large File Storage for binary files
    # lfs.enable = true;
  };
}
