{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/default
      ../../modules/steam
      ../../modules/workstation
      ../../modules/camlink
      ../../modules/vpn
    ];

  networking.hostName = "mir";
  networking.hostId = "6fb90b34";

  # Unfortunately Kubernetes E2E tests fail with unified cgroups
  systemd.enableUnifiedCgroupHierarchy = false;

  boot = {
    kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 15;
      };
      timeout = 3;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "igb" ];

      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 4242;
          hostKeys = [
            "/etc/secrets/initrd/ssh_host_rsa_key"
            "/etc/secrets/initrd/ssh_host_ed_25519_key"
          ];
        };
      };
    };
  };

  boot.initrd.luks.devices = {
    zfsPool = {
      device = "/dev/nvme0n1p1";
    };
    swap = {
      device = "/dev/nvme0n1p2";
    };
    docker = {
      device = "/dev/nvme0n1p5";
    };
  };

  fileSystems."/mnt/nas-home" =
    { device = "192.168.2.55:storage/home/danielle";
      fsType = "nfs";
    };

  services.xserver.videoDrivers = [ "vmware" ];

  virtualisation.vmware.guest.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "wheel" ];

  virtualisation.docker = {
    storageDriver = "overlay2";
    enableNvidia = true;
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      docker = pkgs.docker.override { buildxSupport = true; };
    };
  };

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
    nix
    efibootmgr
    open-vm-tools
  ];

  services.rpcbind.enable = true;

  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "plugdev" "networkmanager" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "19.09";
}

