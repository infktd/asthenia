# Hyprland compositor + greetd session
{ pkgs, lib, inputs, ... }: {
  imports = [ ./desktop.nix inputs.hyprland.nixosModules.default ];

  programs.hyprland = { enable = true; xwayland.enable = true; };

  services.greetd = {
    enable = true;
    settings = rec {
      tuigreet_session = let
        session = "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/bin/start-hyprland";
        tuigreet = "${lib.exe pkgs.tuigreet}";
      in { command = "${tuigreet} --time --remember --cmd ${session}"; user = "greeter"; };
      default_session = tuigreet_session;
    };
  };

  xdg.portal = {
    enable = true; config.common.default = [ "hyprland" "gtk" ];
    extraPortals = with pkgs; [
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
}
