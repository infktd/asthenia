# =============================================================================
# ZELLIJ TERMINAL MULTIPLEXER CONFIGURATION
# =============================================================================
# Terminal workspace manager with tiling, tabs, and session management
#
# ZELLIJ FEATURES:
# - Native Wayland/macOS support
# - Floating panes
# - Plugin system
# - Session persistence
#
# KEYBINDINGS (Alt-based for Neovim compatibility):
# - Alt + h/j/k/l: Move focus between panes
# - Alt + 1-5: Switch tabs
# - Alt + d/r: New pane down/right
# - Alt + z: Toggle fullscreen
# - Alt + t: Toggle floating panes
# - Alt + /: Show keybind hints
#
# LAYOUTS:
# - dev: Multi-pane for active development (editor + claude + terminal)
# - focus: Minimal single-pane per tab
# =============================================================================
{ config, pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;

    # Enable shell integration
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  # ---------------------------------------------------------------------------
  # ZELLIJ CONFIG FILES
  # ---------------------------------------------------------------------------
  # Using raw KDL files for full control over syntax
  home.file = {
    # -------------------------------------------------------------------------
    # MAIN CONFIGURATION
    # -------------------------------------------------------------------------
    ".config/zellij/config.kdl".text = ''
      // Zellij Configuration
      // Terminal-based Neovim + Claude Code workflow

      // ==========================================================================
      // BEHAVIOR SETTINGS
      // ==========================================================================

      // Kill session when terminal closes (no zombie sessions)
      on_force_close "quit"

      // Don't serialize sessions to disk (reduces resource usage)
      session_serialization false

      // Default layout
      default_layout "dev"

      // Copy to system clipboard
      copy_on_select true

      // Use system clipboard (platform-aware)
      copy_command "${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"

      // Scrollback buffer
      scroll_buffer_size 50000

      // Mouse support
      mouse_mode true

      // Mirror session for UI consistency
      mirror_session true

      // Theme
      theme "catppuccin-mocha"

      // ==========================================================================
      // KEYBINDINGS
      // ==========================================================================

      keybinds clear-defaults=true {
          // ----------------------------------------------------------------------
          // NORMAL MODE
          // ----------------------------------------------------------------------
          normal {
              // Pane navigation (Alt + hjkl)
              bind "Alt h" { MoveFocus "Left"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
              bind "Alt l" { MoveFocus "Right"; }

              // Tab switching (Alt + number)
              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt 5" { GoToTab 5; }

              // Tab cycling (Alt + [ / ])
              bind "Alt [" { GoToPreviousTab; }
              bind "Alt ]" { GoToNextTab; }

              // Floating terminal toggle (Alt + t)
              bind "Alt t" { ToggleFloatingPanes; }

              // Pane management
              bind "Alt d" { NewPane "Down"; }
              bind "Alt r" { NewPane "Right"; }
              bind "Alt q" { CloseFocus; }

              // Resize mode (Alt + =)
              bind "Alt =" { SwitchToMode "Resize"; }

              // Fullscreen toggle for current pane (Alt + z)
              bind "Alt z" { ToggleFocusFullscreen; }

              // New tab (Alt + n)
              bind "Alt n" { NewTab; }

              // Scroll mode (Alt + s)
              bind "Alt s" { SwitchToMode "Scroll"; }

              // Session management (Alt + Shift)
              bind "Alt D" { Detach; }
              bind "Alt Q" { Quit; }

              // Sync input to all panes
              bind "Alt S" { ToggleActiveSyncTab; }

              // Quick layout switching
              bind "Alt f" { GoToTab 1; ToggleFocusFullscreen; }
              bind "Alt w" { NewPane "Right"; }

              // Show keybind hints (Alt + /)
              bind "Alt /" {
                  Run "bash" "-c" "clear && cat ~/.config/zellij/hints.txt && read -n1" {
                      direction "Down"
                      close_on_exit true
                  }
              }
          }

          // ----------------------------------------------------------------------
          // RESIZE MODE
          // ----------------------------------------------------------------------
          resize {
              bind "h" { Resize "Left"; }
              bind "j" { Resize "Down"; }
              bind "k" { Resize "Up"; }
              bind "l" { Resize "Right"; }
              bind "=" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
              bind "Esc" { SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
          }

          // ----------------------------------------------------------------------
          // SCROLL MODE
          // ----------------------------------------------------------------------
          scroll {
              bind "j" { ScrollDown; }
              bind "k" { ScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "Esc" { SwitchToMode "Normal"; }
              bind "q" { SwitchToMode "Normal"; }
          }

          // ----------------------------------------------------------------------
          // SHARED BINDINGS
          // ----------------------------------------------------------------------
          shared {
              bind "Alt h" { MoveFocus "Left"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
              bind "Alt l" { MoveFocus "Right"; }
          }

          shared_except "normal" {
              bind "Esc" { SwitchToMode "Normal"; }
          }
      }

      // ==========================================================================
      // PLUGINS
      // ==========================================================================

      plugins {
          tab-bar location="zellij:tab-bar"
          status-bar location="zellij:status-bar"
          strider location="zellij:strider"
          compact-bar location="zellij:compact-bar"
          session-manager location="zellij:session-manager"
      }

      // ==========================================================================
      // UI SETTINGS
      // ==========================================================================

      ui {
          pane_frames {
              rounded_corners true
              hide_session_name true
          }
      }

      // Enable pane frames
      pane_frames true

      // Styled borders
      styled_underlines true

      // Show mode indicators
      simplified_ui false

      // Hide session metadata
      disable_session_metadata true
    '';

    # -------------------------------------------------------------------------
    # KEYBIND HINTS
    # -------------------------------------------------------------------------
    ".config/zellij/hints.txt".text = ''

  ZELLIJ KEYBINDS
  ═══════════════════════════════════════

  NAVIGATION
  ───────────────────────────────────────
  Alt + h/j/k/l     Move focus between panes
  Alt + 1/2/3/4/5   Switch to tab N
  Alt + [ / ]       Previous / Next tab

  PANES
  ───────────────────────────────────────
  Alt + d           New pane below
  Alt + r           New pane right
  Alt + q           Close current pane
  Alt + z           Toggle fullscreen
  Alt + t           Toggle floating pane

  MODES
  ───────────────────────────────────────
  Alt + =           Resize mode
                      h/j/k/l = resize direction
                      =/- = grow/shrink
                      Esc = exit

  Alt + s           Scroll mode
                      j/k = scroll
                      d/u = half page
                      Esc = exit

  OTHER
  ───────────────────────────────────────
  Alt + n           New tab
  Alt + f           Focus mode (fullscreen tab 1)
  Alt + w           Split right
  Alt + D           Detach session
  Alt + Q           Quit zellij (exit all)
  Alt + S           Sync input to all panes
  Alt + /           Show this help

  ═══════════════════════════════════════
        Press any key to close

    '';

    # -------------------------------------------------------------------------
    # FOCUS LAYOUT
    # -------------------------------------------------------------------------
    ".config/zellij/layouts/focus.kdl".text = ''
      // Focus Layout - Minimal, distraction-free
      // Single pane per tab for deep work

      layout {
          default_tab_template {
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
              children
          }

          // TAB 1: EDIT
          tab name="edit" focus=true {
              pane name="editor"
          }

          // TAB 2: CLAUDE
          tab name="claude" {
              pane name="claude"
          }

          // TAB 3: SERVER
          tab name="srv" {
              pane name="server"
          }
      }
    '';

    # -------------------------------------------------------------------------
    # DEV LAYOUT
    # -------------------------------------------------------------------------
    ".config/zellij/layouts/dev.kdl".text = ''
      // Dev Layout - Multi-pane for active development
      // Editor-focused with claude code and terminal visible

      layout {
          default_tab_template {
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
              children
          }

          // TAB 1: EDIT - main workspace
          // +------------------+--------+
          // |                  |        |
          // |     EDITOR       |        |
          // |      (70%)       | CLAUDE |
          // +------------------+  (30%) |
          // |     TERMINAL     |        |
          // +------------------+--------+
          tab name="edit" focus=true {
              pane split_direction="vertical" {
                  pane size="70%" split_direction="horizontal" {
                      pane size="75%" name="editor"
                      pane name="terminal"
                  }
                  pane name="claude"
              }
          }

          // TAB 2: CLAUDE - full screen claude
          tab name="claude" {
              pane name="claude"
          }

          // TAB 3: SERVER
          tab name="srv" {
              pane name="server"
          }
      }
    '';
  };
}
