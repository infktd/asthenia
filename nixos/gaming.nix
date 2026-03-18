# Steam and GameMode
{ ... }: {

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    remotePlay.openFirewall = true;
  };
}
