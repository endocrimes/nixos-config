{ config, pkgs, ... }:

let stable = import <nixos-stable> { };
in {
  imports = [ # Include the results of the hardware scan.
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen>
    ./hardware-configuration.nix
    ../imports/defaults.nix
    ../imports/graphical.nix
    ../imports/audio.nix
    ../imports/yubikey.nix
    ../imports/remote-builds
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.plymouth.enable = true;

  boot.initrd.luks.devices = {
    env-pv = {
      preLVM = true;
      device = "/dev/nvme0n1p2";
    };
  };

  boot.zfs.devNodes = "/dev";
  boot.tmpOnTmpfs = true;
  hardware.cpu.intel.updateMicrocode = true;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    monthly = 1;
  };

  # Dammit Valve get your shit together
  hardware.opengl.driSupport32Bit = true;

  powerManagement.enable = true;

  # Fix font sizes in X
  services.xserver.dpi = 210;
  fonts.fontconfig.dpi = 210;

  # Fix sizes of GTK/GNOME ui elements
  # environment.variables = {
  #   GDK_SCALE = lib.mkDefault "1.5";
  #   GDK_DPI_SCALE= lib.mkDefault "0.75";
  # };


  networking.hostName = "mew";
  networking.hostId = "41434142";

  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random"; /* Randomise the MAC address between connections */
  };

  environment.systemPackages = with pkgs; [
    firefox
    acpilight
    feh
    davfs2
    brightnessctl

    # https://github.com/NixOS/nixpkgs/issues/72034
    stable.nix
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable dconf for pulseaudio settings
  programs.dconf.enable = true;

  # Enable usbmuxd for iOS tethering
  services.usbmuxd.enable = true;

  ## :fire: :brick:
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  services.logind.lidSwitch = "hybrid-sleep";
  services.logind.lidSwitchExternalPower = "suspend";

  services.fwupd.enable = true;

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/10 * * * *    danielle   . /etc/profile; /home/danielle/.config/mutt/etc/mailsync.sh"
    ];
  };

  location.provider = "geoclue2";
  services.redshift = {
    enable = true;
  };

  virtualisation.docker.enable = true;

  users.groups.davfs2 = {};
  users.groups.dialout = {};

  users.users.davfs2 = {
    isNormalUser = false;
    extraGroups = [ "davfs2" ];
  };

  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "docker" "avahi" "dialout" "davfs2" "journalctl" ];
    shell = pkgs.zsh;
  };

  # services.nomad.enable = true;

  system.stateVersion = "19.03";
}
