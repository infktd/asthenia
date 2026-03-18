# Zellij terminal multiplexer
{ config, pkgs, lib, ... }: {
  programs.zellij = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  home.file = {
    ".config/zellij/config.kdl".text = ''
      on_force_close "quit"
      session_serialization false
      default_layout "dev"
      copy_on_select true
      copy_command "${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"
      scroll_buffer_size 50000
      mouse_mode true
      mirror_session true
      theme "catppuccin-mocha"

      keybinds clear-defaults=true {
          normal {
              bind "Alt h" { MoveFocus "Left"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
              bind "Alt l" { MoveFocus "Right"; }
              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt 5" { GoToTab 5; }
              bind "Alt [" { GoToPreviousTab; }
              bind "Alt ]" { GoToNextTab; }
              bind "Alt t" { ToggleFloatingPanes; }
              bind "Alt d" { NewPane "Down"; }
              bind "Alt r" { NewPane "Right"; }
              bind "Alt q" { CloseFocus; }
              bind "Alt =" { SwitchToMode "Resize"; }
              bind "Alt z" { ToggleFocusFullscreen; }
              bind "Alt n" { NewTab; }
              bind "Alt s" { SwitchToMode "Scroll"; }
              bind "Alt D" { Detach; }
              bind "Alt Q" { Quit; }
              bind "Alt S" { ToggleActiveSyncTab; }
              bind "Alt f" { GoToTab 1; ToggleFocusFullscreen; }
              bind "Alt w" { NewPane "Right"; }
              bind "Alt /" {
                  Run "bash" "-c" "clear && cat ~/.config/zellij/hints.txt && read -n1" {
                      direction "Down"
                      close_on_exit true
                  }
              }
          }
          resize {
              bind "h" { Resize "Left"; }  bind "j" { Resize "Down"; }
              bind "k" { Resize "Up"; }    bind "l" { Resize "Right"; }
              bind "=" { Resize "Increase"; }  bind "-" { Resize "Decrease"; }
              bind "Esc" { SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
          }
          scroll {
              bind "j" { ScrollDown; }  bind "k" { ScrollUp; }
              bind "d" { HalfPageScrollDown; }  bind "u" { HalfPageScrollUp; }
              bind "Esc" { SwitchToMode "Normal"; }
              bind "q" { SwitchToMode "Normal"; }
          }
          shared {
              bind "Alt h" { MoveFocus "Left"; }  bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }    bind "Alt l" { MoveFocus "Right"; }
          }
          shared_except "normal" {
              bind "Esc" { SwitchToMode "Normal"; }
          }
      }

      plugins {
          tab-bar location="zellij:tab-bar"
          status-bar location="zellij:status-bar"
          strider location="zellij:strider"
          compact-bar location="zellij:compact-bar"
          session-manager location="zellij:session-manager"
      }

      ui {
          pane_frames { rounded_corners true  hide_session_name true }
      }
      pane_frames true
      styled_underlines true
      simplified_ui false
      disable_session_metadata true
    '';

    ".config/zellij/hints.txt".text = ''

  ZELLIJ KEYBINDS
  ═══════════════════════════════════════
  NAVIGATION           Alt+h/j/k/l  Move focus    Alt+1-5  Tab N    Alt+[/]  Prev/Next tab
  PANES                Alt+d  Below    Alt+r  Right    Alt+q  Close    Alt+z  Fullscreen    Alt+t  Float
  MODES                Alt+=  Resize (h/j/k/l, =/-)    Alt+s  Scroll (j/k, d/u)    Esc  Exit mode
  OTHER                Alt+n  New tab    Alt+D  Detach    Alt+Q  Quit    Alt+S  Sync    Alt+/  Help
  ═══════════════════════════════════════
        Press any key to close
    '';

    ".config/zellij/layouts/focus.kdl".text = ''
      layout {
          default_tab_template {
              pane size=1 borderless=true { plugin location="compact-bar" }
              children
          }
          tab name="edit" focus=true { pane name="editor" }
          tab name="claude" { pane name="claude" }
          tab name="srv" { pane name="server" }
      }
    '';

    ".config/zellij/layouts/dev.kdl".text = ''
      layout {
          default_tab_template {
              pane size=1 borderless=true { plugin location="compact-bar" }
              children
          }
          tab name="edit" focus=true {
              pane split_direction="vertical" {
                  pane size="70%" split_direction="horizontal" {
                      pane size="75%" name="editor"
                      pane name="terminal"
                  }
                  pane name="claude"
              }
          }
          tab name="claude" { pane name="claude" }
          tab name="srv" { pane name="server" }
      }
    '';
  };
}
