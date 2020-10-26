{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/default
    ../../modules/nix/remote-builds
    ../../modules/workstation
    ../../modules/vpn
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_5_8;
  boot.plymouth.enable = true;

  boot.initrd.luks.devices = {
    swap = {
      device = "/dev/nvme0n1p2";
    };
    zfs = {
      device = "/dev/nvme0n1p3";
    };
    docker = {
      device = "/dev/nvme0n1p4";
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
  hardware.pulseaudio.support32Bit = true;

  powerManagement.enable = true;

  # Fix font sizes in X
  services.xserver.dpi = 210;
  fonts.fontconfig.dpi = 210;

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
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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

  services.printing.enable = true;

  services.restic.backups = {
    nasbackup = {
      initialize = true;
      # This is really sad because it means the pw ends up in my nix store, but
      # I don't really have a better solution right now.
      repository = "rest:https://${lib.removeSuffix "\n" (builtins.readFile /etc/nixos/secrets/restic/mewpw)}@backups.terrible.systems/danielle-mew";
      passwordFile = "/etc/nixos/secrets/restic/mewpw";
      paths = [
        "/home/danielle"
      ];
      extraBackupArgs = [
        "--exclude=/home/danielle/.local"
        "--exclude=/home/danielle/.steam"
        "--exclude=/home/danielle/.cache"
        "--exclude=/home/danielle/.zoom"
        "--exclude=/home/danielle/.vscode"
        "--exclude=/home/danielle/.mozilla"
      ];
      pruneOpts = [
        "--keep-daily 4"
        "--keep-weekly 1"
        "--keep-monthly 1"
        "--keep-yearly 99"
      ];
    };
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

  system.stateVersion = "19.03";
}
