{ config, lib, pkgs, ... }:

# camlink is a nixos module that installs the tools required to use an Elgato
# CamLink as a webcam. This is mostly just setting up v4l2.
{
  config.boot.extraModulePackages = with pkgs; [
    config.boot.kernelPackages.v4l2loopback
  ];

  config.boot.kernelModules = [
    "v4l2loopback"
  ];

  config.boot.extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7II
  '';

  config.environment.systemPackages = with pkgs; [
    ffmpeg
    v4l-utils
  ];
}
