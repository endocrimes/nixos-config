{ config, pkgs, lib, isGUISystem, ... }:

{
  home.packages = with pkgs; lib.optionals (isGUISystem) [
    # Chat
    signal-desktop
    quasselClient
    keybase-gui
    tdesktop
    skypeforlinux
  ];

  services.keybase.enable = isGUISystem;
  services.kbfs.enable = isGUISystem;
}
