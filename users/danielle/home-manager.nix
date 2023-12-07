{ stdenv, config, pkgs, lib, isGUISystem, ... }:

let
  whenGUI = attrs: if isGUISystem then attrs else [];
in {
  imports = [
    ./modules/base
    ./modules/develop
  ];

  programs.firefox = {
    enable = isGUISystem;
  };

  home.stateVersion = "22.05";

  home.packages = with pkgs; [
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  systemd.user.startServices = true;

  services.syncthing = { enable = pkgs.stdenv.isLinux; };
}

