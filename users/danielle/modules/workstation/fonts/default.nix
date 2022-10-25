{ config, pkgs, lib, isGUISystem, ... }:

{
  home.packages = with pkgs; lib.optionals (isGUISystem) [
    fira-code
    siji
    unifont
    fantasque-sans-mono
  ];
}
