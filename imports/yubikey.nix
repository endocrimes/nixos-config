{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-personalization-gui
    yubikey-manager
    yubikey-manager-qt
    yubikey-neo-manager
    yubioath-desktop
    yubico-piv-tool
  ];

  services.udev.packages = with pkgs; [
    libu2f-host
    yubikey-personalization
  ];

  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    cue = true;
  };

  services.pcscd.enable = true;
}
