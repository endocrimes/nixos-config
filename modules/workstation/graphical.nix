{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [ twemoji-color-font nerdfonts ];

  boot.plymouth.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e, caps:ctrl_modifier, altwin:swap_alt_win";
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager = {
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };
    displayManager = {
      defaultSession = "xfce+i3";
      lightdm = {
        enable = true;
        background = "/etc/background-image.png";
      };
    };

    ## Enable touchpad support.
    libinput = {
      enable = true;
      naturalScrolling = true;
    };

    deviceSection = ''
      Option "DRI" "2"
      Option "TearFree" "true"
    '';
  };
}
