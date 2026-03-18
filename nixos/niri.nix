# Niri compositor + DMS shell + greetd session
{ pkgs, lib, inputs, ... }: {
  imports = [ ./desktop.nix inputs.dms.nixosModules.dank-material-shell inputs.niri-flake.nixosModules.niri ];

  programs.dms-shell = {
    enable = true; enableAudioWavelength = true; enableDynamicTheming = true;
    enableSystemMonitoring = true; systemd = { enable = true; restartIfChanged = true; };
  };
  programs.niri = { enable = true; package = pkgs.niri-unstable; };

  services.greetd = {
    enable = true;
    settings = rec {
      tuigreet_session = let
        session = "${pkgs.niri-unstable}/bin/niri-session";
        tuigreet = "${lib.exe pkgs.tuigreet}";
      in { command = "${tuigreet} --time --remember --cmd ${session}"; user = "greeter"; };
      default_session = tuigreet_session;
    };
  };

  systemd.user.services.dms.wantedBy = lib.mkForce [ "niri.service" ];
  systemd.user.services.niri-flake-polkit.enable = false;

  xdg.portal = {
    enable = true; config.common.default = [ "gtk" ];
    extraPortals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk ];
  };
}
