{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib.file) mkOutOfStoreSymlink;

  nerdFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
  ];

  fontPkgs = with pkgs; [
    font-awesome # awesome fonts
    material-design-icons # fonts with glyphs
  ] ++ nerdFonts;

  audioPkgs = with pkgs; [
    paprefs # pulseaudio preferences
    pasystray # pulseaudio systray
    pavucontrol # pulseaudio volume control
    playerctl # music player controller
    pulsemixer # pulseaudio mixer
  ];

  packages = with pkgs; [
    brightnessctl # control laptop display brightness
    grim # screenshots
    libnotify # notifications
    nemo # file manager
    networkmanagerapplet # network manager systray app
    wl-clipboard # clipboard support
  ] ++ fontPkgs ++ audioPkgs;
in
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  services.polkit-gnome.enable = true;

  imports = [
    ../../shared
    ../../programs/firefox/firefox.nix
    ../../programs/fuzzle/fuzzle.nix
    ../../programs/kitty/kitty.nix
    ../../programs/nvf/nvf.nix
    ../../programs/vscode/vscode.nix
    ../../programs/discord/discord.nix
    ../../programs/obsidian/obsidian.nix
    ../../programs/yazi/yazi.nix
  ];

  home = {
    inherit packages;
    stateVersion = "24.11";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      SHELL = "${lib.exe pkgs.fish}";
      MOZ_ENABLE_WAYLAND = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };

  fonts.fontconfig.enable = true;

  # e.g. for slack, etc
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "gtk" "gnome" ];
      };
      niri = {
        default = [ "gtk" "gnome" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    xdgOpenUsePortal = true;
  };
}
