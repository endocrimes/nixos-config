{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;
  

  networking.hostName = "mrow"; # Define your hostname.
  networking.hostId = "44414e49";
  networking.networkmanager.enable = true;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    monthly = 3;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    zsh
  ];

  programs.mtr.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 80 443
    445 139 # samba
  ];
  networking.firewall.allowedUDPPorts = [
    137 138 # samba
  ];
  networking.firewall.allowPing = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  virtualisation.docker.enable = true;
  
  environment.shells = [ pkgs.zsh ];
  
  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "dialout" ];
    shell = pkgs.zsh;
    hashedPassword = builtins.readFile ./passwd-danielle; 
  };

  nixpkgs.config.allowUnfree = true;

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.terrible.systems";
    home = "/spool/nextcloud";
    https = true;

    nginx.enable = true;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/etc/nixos/passwd-nextcloud";
      adminuser = "root";
    };
  };

  services.nginx.virtualHosts."nextcloud.terrible.systems" = {
    enableACME = true;
    forceSSL = true;
  };

  services.nginx.virtualHosts."plex.terrible.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.178.72:32400";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
     { name = "nextcloud";
       ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
     }
    ];
  };

  services.samba = {
    package = pkgs.sambaFull;
    enable = true;
    securityType = "user";
    extraConfig = ''
      hosts allow = 192.168.0 localhost 192.168.178.0/24 
      hosts deny = 0.0.0.0/0
    '';
    shares = {
      storage = {
        path = "/spool/storage";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
