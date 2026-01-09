# This is a placeholder hardware configuration file.
# Generate your actual hardware configuration with:
#   nixos-generate-config --show-hardware-config > system/hardware-configuration.nix
#
# Or run it on your system:
#   sudo nixos-generate-config

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # Placeholder boot configuration
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Placeholder filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Placeholder swap
  swapDevices = [ ];

  # Placeholder networking
  networking.useDHCP = lib.mkDefault true;

  # Placeholder hardware
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
