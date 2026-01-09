{ config, lib, pkgs, ... }:

{
  # Machine-specific configuration for 'arasaka'
  # Override base system settings here

  networking.hostName = "arasaka"; # Change this to your hostname

  # Import hardware configuration
  imports = [ 
    ./hardware-configuration.nix 
    ../../wm/niri.nix
  ];

  # Machine-specific overrides
  # services.xserver.enable = true;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
}
