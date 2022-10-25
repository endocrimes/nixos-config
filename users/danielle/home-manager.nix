{ stdenv, config, pkgs, lib, isGUISystem, ... }:

let
  whenGUI = attrs: if isGUISystem then attrs else [];
in {
  imports = [
    ./modules/base
    ./modules/develop
    ./modules/email
    ./modules/graphical/i3
    ./modules/workstation
    ./modules/workworkwork
  ];

  programs.firefox = {
    enable = isGUISystem;
  };

  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    python27
    gnupg
    pinentry
    syncthing
    ripgrep
  ] ++ (whenGUI
    [
      keybase-gui
      gimp
      xclip
    ]);

  systemd.user.startServices = true;

  services.syncthing = { enable = pkgs.stdenv.isLinux; };
}

