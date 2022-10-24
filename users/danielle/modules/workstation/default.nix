{ config, pkgs, ... }:

{
  imports =
    [ ./fonts ./chat ./terminal ./entertainment ./yubikey.nix ];

  home.packages = with pkgs; [
    # Configure Planck
    wally-cli

    # xclip. why.
    xclip

    # Useful for checking that my webcam works
    gnome3.cheese
  ];
}
