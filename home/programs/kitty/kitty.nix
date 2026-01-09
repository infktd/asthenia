{ config, lib, ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    theme = "OneDark";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = config.programs.kitty.fontsize or 12;
    };
    settings = {
      background_opacity = "0.9";
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };
}
