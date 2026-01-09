{inputs, ... }:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs.dankMaterialShell = {
    enable = true;
    niri = {
      enableKeybinds = false;   # Sets static preset keybinds
      enableSpawn = true;       # Auto-start DMS with niri and cliphist, if enabled
    };

    default.settings = {
      theme = "dark";
      dynamicTheming = true;
    };
  };
}
