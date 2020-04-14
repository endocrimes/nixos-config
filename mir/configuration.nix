# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  stable = import <nixos-stable> { };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/default
      ../modules/workstation
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mir";
  networking.hostId = "6fb90b34";

  boot.initrd.luks.devices = {
    zfsPool = {
      device = "/dev/nvme0n1p1";
    };
    swap = {
      device = "/dev/nvme0n1p2";
    };
  };

  fileSystems."/mnt/nas-home" =
    { device = "192.168.178.105:spool/home/danielle";
      fsType = "nfs";
    };

  boot.plymouth.enable = true;

  hardware.openrazer.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    monthly = 1;
  };

  environment.systemPackages = with pkgs; [
    firefox
    feh

    libnfs
    nfs-utils

    vscode

    # https://github.com/NixOS/nixpkgs/issues/72034
    stable.nix

    # Management for H100i Platinum cooler
    opencorsairlink
  ];

  services.rpcbind.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp10s0f1u3u4i5.useDHCP = true;
  networking.interfaces.enp8s0.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "plugdev" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

