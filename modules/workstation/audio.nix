{ config, pkgs, ... }:

{
  sound.enable = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    zeroconf.discovery.enable = true;
  };

  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    pasystray
    paprefs
    pamixer
    pavucontrol
  ];
}
