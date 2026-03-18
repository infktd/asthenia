# Niri user config: KDL config files
{ ... }: {
  imports = [ ../wayland.nix ];

  xdg.configFile."niri/config.kdl".source = ./config/config.kdl;
  xdg.configFile."niri/input.kdl".source = ./config/input.kdl;
  xdg.configFile."niri/keybindings.kdl".source = ./config/keybindings.kdl;
  xdg.configFile."niri/layout.kdl".source = ./config/layout.kdl;
  xdg.configFile."niri/outputs.kdl".source = ./config/outputs.kdl;
  xdg.configFile."niri/rules.kdl".source = ./config/rules.kdl;
  xdg.configFile."niri/workspaces.kdl".source = ./config/workspaces.kdl;
}
