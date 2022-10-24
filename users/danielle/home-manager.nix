{ stdenv, config, pkgs, ... }:

{
  imports = [
    ./modules/base
    ./modules/develop
    ./modules/email
  ] ++ if config.args.isGUISystem then
  [
    ./modules/graphical/i3
    ./modules/workstation
    ./modules/workworkwork
  ] else [];

  programs.firefox = {
    enable = config.args.isGUISystem;
  };

  home.packages = with pkgs; [
    python27
    gnupg
    pinentry
    syncthing
    ripgrep
  ] // if config.args.isGUISystem then
    [
      keybase-gui
      gimp
      xclip
    ] else [];

  systemd.user.startServices = true;

  services.syncthing = { enable = true; };

  services.keybase.enable = true;

  services.kbfs = { enable = true; };
}

