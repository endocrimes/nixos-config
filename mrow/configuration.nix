{ config, pkgs, lib, ... }:

let unstable = import <unstable> {
    # Include the nixos config when importing nixos-unstable
    # But remove packageOverrides to avoid infinite recursion
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
}; in
{
  disabledModules = [ "services/web-apps/nextcloud.nix" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../imports/defaults.nix
      ../imports/server.nix
      # Override the nextcloud module
      <unstable/nixos/modules/services/web-apps/nextcloud.nix>
    ];

  # Override select packages to use the unstable channel
  nixpkgs.config.packageOverrides = pkgs: {
    nextcloud = unstable.nextcloud;
  };

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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 80 443 1443
    8080 # calibre
    445 139 # samba
  ];
  networking.firewall.allowedUDPPorts = [
    137 138 # samba
  ];
  networking.firewall.allowPing = true;

  services.openssh = {
    ports = [22 1433];

    passwordAuthentication = false;
  };

  virtualisation.docker.enable = true;

  users.groups.nix-trusted = {};
  users.groups.media = {};

  nix = {
    trustedUsers = [ "@nix-trusted" ];
  };

  users.users.ellipse = {
    isNormalUser = true;
    extraGroups = [ "media" ];
    initialHashedPassword = builtins.readFile ./passwd-ellipse;
  };

  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "dialout" "nix-trusted" ];
    shell = pkgs.zsh;
    hashedPassword = builtins.readFile ./passwd-danielle;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy6nsIHNmq0zzkXbjutADn2cjOoLjz70+yQPnDku9Da/BdmjQEoArsojI/l5WuP0D2+xUXEOLQonGF1LKdBiBrCn775PVF/wd4MlW1a7uyXiFlYu4a2H8dgaQ79E85/Tpzc9AwzkVb+vq1oii49yQFarc7RHrqXikQ9yDTqWZQ5BYZUSXZVZ+ZCct9Y/3xxQyMD7i1eTaf7t2HfIUusAVzIXfpUfFQ2XxUyoJtRrG2hgTIdUikN0+JDD8Th1d+rPIw+uYNwbrw9qEpMY8MXT4Od8i7/j8Wwyo4iOF04n2nNmV+p1ToQ6iiduZZZ3/npRdhzbgXJK5TNq98R66Igiit" # mew
    ];
  };

  users.users.maxine = {
   isNormalUser = true;
   extraGroups = [ "nix-trusted" "wheel" "docker" ];
   shell = pkgs.fish;
   openssh.authorizedKeys.keys = [
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDmex7rvB7BFd9OxQHfgqKogiN69kHvixCzWWEGh5oY"
   ];
  };

  nixpkgs.config.allowUnfree = true;

  services.calibre-server = {
    enable = false;
    libraryDir = "/spool/storage/calibre-library";
  };

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

  services.minio = {
    enable = true;
    listenAddress = ":9002";
    dataDir = "/spool/storage/minio/data";
    configDir = "/spool/storage/minio/config";
    region = "eu-dani-1";
  };

  services.nix-serve = {
    enable = true;
    port = 9003;
    secretKeyFile = "/var/bincache.d/cache-priv-key.pem";
  };

  services.nginx.virtualHosts."minio.terrible.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9002";
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

  services.nginx.virtualHosts."nixcache.infra.terrible.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      proxy_pass http://localhost:${toString config.services.nix-serve.port};
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    '';
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
      media = {
        path = "/spool/storage/media";
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
