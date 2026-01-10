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
    
    # Force full composition pipeline for better Wayland performance
    forceFullCompositionPipeline = true;
  };

  # Enable graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
