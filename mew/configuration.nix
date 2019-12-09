{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen>
    ./hardware-configuration.nix
    ../imports/defaults.nix
    ../imports/graphical.nix
    ../imports/audio.nix
    ../imports/yubikey.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.extraModulePackages = [
    config.boot.kernelPackages.exfat-nofuse
    config.boot.kernelPackages.wireguard
  ];

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

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.192.122.2/32" ];
      privateKeyFile = "/etc/boot-secrets/wg0-key";
      peers = [
        {
          publicKey = "rIIZ3OBz6LNsSgGI/oDJCf4Aqd5YIkjmrFOcigGoim4=";

          allowedIPs = [
            # Forward all traffic from the wireguard IP range
            "10.192.122.0/24"
          ];

          # Set this to the server IP and port.
          endpoint = "vpn.terrible.systems:51820";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };

  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random"; /* Randomise the MAC address between connections */
  };

  environment.systemPackages = with pkgs; [
    firefox
    acpilight
    feh
    davfs2
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable dconf for pulseaudio settings
  programs.dconf.enable = true;

  # List services that you want to enable:

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

  services.redshift = {
    enable = true;
    provider = "geoclue2";
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "danielle" ];

  users.groups.davfs2 = {};
  users.groups.dialout = {};

  users.users.davfs2 = {
    isNormalUser = false;
    extraGroups = [ "davfs2" ];
  };

  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "docker" "avahi" "dialout" "davfs2" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "19.03";
}
