{ config, lib, pkgs, ... }:

{
  # Machine-specific configuration for 'arasaka'
  # Override base system settings here

  networking.hostName = "arasaka"; # Change this to your hostname

  # Import hardware configuration
  imports = [ ./hardware-configuration.nix ];

  # Machine-specific overrides
  # services.xserver.enable = true;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
}
