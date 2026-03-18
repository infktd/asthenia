# Hyprpaper wallpaper daemon
{ ... }: {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true; splash = false;
      wallpaper = [
        { monitor = "DP-1"; path = "/home/infktd/Wallpaper/pawel-czerwinski-379VdcbeFaQ-unsplash.jpg"; }
        { monitor = "DP-2"; path = "/home/infktd/Wallpaper/pawel-czerwinski-379VdcbeFaQ-unsplash.jpg"; }
      ];
    };
  };
}
