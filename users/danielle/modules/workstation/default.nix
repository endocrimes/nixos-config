{ config, pkgs, lib, isGUISystem, ... }:

{
  imports = [ ./fonts ./chat ./entertainment ./yubikey.nix ];

  home.packages = with pkgs; lib.optionals (isGUISystem) [
    # Configure Planck
    wally-cli

    kitty

    # xclip. why.
    xclip

    # Useful for checking that my webcam works
    gnome3.cheese
  ];
}
