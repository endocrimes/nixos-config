{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [ twemoji-color-font ];

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e, caps:ctrl_modifier, altwin:swap_alt_win";
    desktopManager = {
      default = "xfce";
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager = {
      default = "i3";
      i3 = { enable = true; };
    };
    displayManager = {
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

    # Fix screen tearing
    videoDrivers = [ "intel" ];
    deviceSection = ''
      Option "DRI" "2"
      Option "TearFree" "true"
    '';
    useGlamor = true;
  };
}
