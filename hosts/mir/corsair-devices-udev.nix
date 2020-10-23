{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
    # Corsair H100i Platinum SE
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0c19", GROUP="plugdev", MODE="0660"
  '';
}
