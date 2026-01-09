{ config, lib, pkgs, ... }:

{
  # NVIDIA driver configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # Use proprietary driver (more stable)
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}
