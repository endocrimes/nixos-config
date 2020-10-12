{ config, pkgs, ... }:

let
  stable = import <nixos-stable> { };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./corsair-devices-udev.nix
      ../modules/default
      ../modules/workstation
      ../modules/camlink
    ];

  # Enable dconf for pulseaudio settings
  programs.dconf.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.opengl.driSupport32Bit = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "igb" ];

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 4242;
    hostKeys = [
      "/etc/secrets/initrd/ssh_host_rsa_key"
      "/etc/secrets/initrd/ssh_host_ed_25519_key"
    ];
    authorizedKeys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAEYESQFFAIJlMTsZvnv9wSjtyHCNfXvlBgvMazJm2jxvH2SHhY3Cn4cDZk2bW/BdyZJHRmXUSDfYoRsGiTlXTluZwFCFg+5wair9y+gxHaTW+903bJDH1EXnkzzAXkf4OEIyudp9UqsCm8KPPJz9zuhGKw1rzq4e2EJwZ3hKAsWB3zsUA=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy6nsIHNmq0zzkXbjutADn2cjOoLjz70+yQPnDku9Da/BdmjQEoArsojI/l5WuP0D2+xUXEOLQonGF1LKdBiBrCn775PVF/wd4MlW1a7uyXiFlYu4a2H8dgaQ79E85/Tpzc9AwzkVb+vq1oii49yQFarc7RHrqXikQ9yDTqWZQ5BYZUSXZVZ+ZCct9Y/3xxQyMD7i1eTaf7t2HfIUusAVzIXfpUfFQ2XxUyoJtRrG2hgTIdUikN0+JDD8Th1d+rPIw+uYNwbrw9qEpMY8MXT4Od8i7/j8Wwyo4iOF04n2nNmV+p1ToQ6iiduZZZ3/npRdhzbgXJK5TNq98R66Igiit"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhAOEkafj40v3nn2ZQJl2ZlRThfFP+H4sxqmEvicEDg"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5Y4MC0iJA0ftL5kkBJwNjp60npCF8Jfjsd7nQzsF8x"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3bsRW8tLBO3PmpXPrpE635Zu7qOWgWvDRrTm2QQh8Z"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC80KBriR+kXiawNPoBqk8eC6VMXFq7B5QZebqrwoJCTQX7pYrr9wU7WqjjXlYdfPyeZOCbJK/+baBu6OheISt1qfa81C4aKMevU9P4IgtwUN6z44s+xBYhrF/xWrs0CW0SaF+/gM/9nc4Anj9wk7JbFYKqAVbf7KtjtkeS1dUcHo4iIl+Gxx0d3jNoDtkCQBAKpzx4Z4FsA7bD5af3usmfa8YP8eH8VmbNqZY9DXlAr8FZzC7zzRRE7nsshelLTdnve9+wgtE65L6G1k43PsfJXw/kxe2XAb38N2U/ZWw6ZuYvJmF+BKRvPxQhsbie2AT5GH5+AFhQUVPfrZnYwwMWd/F0igc+Iee2nY+knu3OUgeNW50H4yi+/hAkDuyEdyLALg1ttbpWWYlgIhez5k5hY4oi+6H+mRlUV0J431Xk+UwVovzuC8cjjdu0zAWqgTN36DDxiill51Lv5swFi9wUfKoMxMFPA2dZZNmX37h20ftnN2aYSF6B/6Z1ugteB0adsa1lWNdf4/aomWEmvy8GyOQmOIC5KeVsPs5CEKqwLbTiRUYNJDIF7pth1Jq1N6hMCzCEn2qYPMrzXjiHgLAU/ewyT3+wu0FtZGOwEDZj/d1aba26LyxTOJ8H1xb5HHq29StFEfs0OPaXLhVvUSQ9H2jTAj2tTaiVhQ7I02KJGQ=="
    ];
  };

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

    efibootmgr
  ];

  services.rpcbind.enable = true;

  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  users.groups.vmwaremts = {
    gid = 201;
  };

  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "plugdev" "networkmanager" "vmwaremts" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "19.09";
}

