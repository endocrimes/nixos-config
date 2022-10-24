{ stdenv, config, pkgs, ... }:

{
  imports = [
    ./modules/base
    ./modules/workstation
    ./modules/graphical/i3
    ./modules/workworkwork
    ./modules/email
    ./modules/develop
  ];

  home.stateVersion = "22.05";
  home.username = "danielle";
  home.homeDirectory = "/users/danielle";

  programs.firefox = {
    enable = true;
  };

  home.packages = with pkgs; [
    python27
    gnupg
    pinentry

    # xclip. why.
    xclip

    gimp

    syncthing

    keybase-gui
  ];

  systemd.user.startServices = true;

  services.syncthing = { enable = true; };

  services.keybase.enable = true;

  services.kbfs = { enable = true; };
}

