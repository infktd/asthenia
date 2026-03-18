# Mako notification daemon
{ ... }: {
  services.mako = {
    enable = true;
    settings = {
      background-color = "#2b303b"; text-color = "#ffffff";
      border-color = "#65737e"; border-size = 2; border-radius = 8;
      padding = "10"; margin = "10";
      font = "JetBrainsMono Nerd Font 12";
      width = 350; height = 100; anchor = "top-right";
      default-timeout = 5000; ignore-timeout = true;
      group-by = "app-name"; max-visible = 5;
      icons = true; max-icon-size = 48; actions = true;
      progress-color = "over #5588aa";
    };
    extraConfig = ''
      [urgency=low]
      border-color=#65737e
      default-timeout=2000

      [urgency=normal]
      border-color=#ab7967
      default-timeout=5000

      [urgency=critical]
      border-color=#bf616a
      default-timeout=0
    '';
  };
}
