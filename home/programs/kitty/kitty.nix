{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      background_opacity = "0.75";
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };
}
