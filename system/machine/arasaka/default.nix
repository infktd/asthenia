{ config, lib, pkgs, ... }:

{
  # === IMPORTS ===
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ../../wm/hyprland.nix
  ];

  # === NETWORKING ===
  networking.hostName = "arasaka";

  # === PROGRAMS ===
  programs.gamemode.enable = true;
  programs.steam = {
    dedicatedServer.openFirewall = true;
    enable = true;
    remotePlay.openFirewall = true;
  };
}
