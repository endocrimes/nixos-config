{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen>
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];

  hardware.brightnessctl.enable = true;

  boot.initrd.luks.devices = [{
    name = "env-pv";
    preLVM = true;
    device = "/dev/nvme0n1p2";
  }];

  boot.zfs.devNodes = "/dev";
  boot.tmpOnTmpfs = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Dammit Valve get your shit together
  hardware.opengl.driSupport32Bit = true;

  powerManagement.enable = true;

  networking.hostName = "mew";
  networking.hostId = "41434142";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
    git
    wget
    firefox
    zsh
    acpilight
    feh
    pasystray
    paprefs
    pamixer
    pavucontrol
    yubikey-personalization
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable dconf for pulseaudio settings
  programs.dconf.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  ## :fire: :brick:
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  ## Zeroconf networking for pulseaudio discovery
  services.avahi = {
    enable = true;
    ipv6 = true;
    nssmdns = true;
  };

  ## Enable CUPS to print documents.
  services.printing.enable = true;

  ## Enable sound.
  sound.enable = true;
  hardware.bluetooth = {
    enable = true;
    extraConfig = ''

            [General]
            Enable=Source,Sink,Media,Socket
          '';
  };
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  ## Enable the X11 windowing system.
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

  fonts.fonts = with pkgs; [ twemoji-color-font ];

  services.logind.lidSwitch = "hybrid-sleep";
  services.logind.lidSwitchExternalPower = "suspend";

  services.fwupd.enable = true;

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/10 * * * *    danielle   . /etc/profile; /home/danielle/.config/mutt/etc/mailsync.sh"
    ];
  };

  services.redshift = {
    enable = true;
    provider = "geoclue2";
  };

  services.udev.packages = with pkgs; [ yubikey-personalization ];

  virtualisation.docker.enable = true;

  environment.shells = [ pkgs.zsh ];

  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "docker" "avahi" "dialout" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "19.03";
}
