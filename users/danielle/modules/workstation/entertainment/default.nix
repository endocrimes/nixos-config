{ config, pkgs, lib, isGUISystem, ... }:

{
  home.packages = with pkgs; lib.optionals (isGUISystem) [
    spotify
    vlc
    playerctl
    mpv
  ];
}
