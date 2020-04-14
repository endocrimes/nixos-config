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
    control = "sufficient";
    cue = true;
  };
  security.pam.services.sudo = {
    u2fAuth = true;
  };

  services.pcscd.enable = true;
}
