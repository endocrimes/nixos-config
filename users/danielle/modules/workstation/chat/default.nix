{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Chat
    signal-desktop
    quasselClient
    keybase-gui
    tdesktop
    skypeforlinux
  ];

  services.keybase.enable = true;
}
