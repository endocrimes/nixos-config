{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/default
      ../../modules/monitoring
      ../../modules/nix/remote-builds
      ../../modules/vpn
    ];

  services.nfs.server.enable = true;
  # need to add echo N > /sys/module/nfsd/parameters/nfs4_disable_idmapping

  environment.systemPackages = with pkgs; [
    unzip
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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    111 2049 33333 # nfs
    22 80 443 1443
    8080 # calibre
    445 139 # samba
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 33333 # nfs
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3bsRW8tLBO3PmpXPrpE635Zu7qOWgWvDRrTm2QQh8Z dani@mir" # mir
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC80KBriR+kXiawNPoBqk8eC6VMXFq7B5QZebqrwoJCTQX7pYrr9wU7WqjjXlYdfPyeZOCbJK/+baBu6OheISt1qfa81C4aKMevU9P4IgtwUN6z44s+xBYhrF/xWrs0CW0SaF+/gM/9nc4Anj9wk7JbFYKqAVbf7KtjtkeS1dUcHo4iIl+Gxx0d3jNoDtkCQBAKpzx4Z4FsA7bD5af3usmfa8YP8eH8VmbNqZY9DXlAr8FZzC7zzRRE7nsshelLTdnve9+wgtE65L6G1k43PsfJXw/kxe2XAb38N2U/ZWw6ZuYvJmF+BKRvPxQhsbie2AT5GH5+AFhQUVPfrZnYwwMWd/F0igc+Iee2nY+knu3OUgeNW50H4yi+/hAkDuyEdyLALg1ttbpWWYlgIhez5k5hY4oi+6H+mRlUV0J431Xk+UwVovzuC8cjjdu0zAWqgTN36DDxiill51Lv5swFi9wUfKoMxMFPA2dZZNmX37h20ftnN2aYSF6B/6Z1ugteB0adsa1lWNdf4/aomWEmvy8GyOQmOIC5KeVsPs5CEKqwLbTiRUYNJDIF7pth1Jq1N6hMCzCEn2qYPMrzXjiHgLAU/ewyT3+wu0FtZGOwEDZj/d1aba26LyxTOJ8H1xb5HHq29StFEfs0OPaXLhVvUSQ9H2jTAj2tTaiVhQ7I02KJGQ== danielle@ipad" # Blink on iPad
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

  security.acme = {
    email = "dani@builds.terrible.systems";
    acceptTerms = true;
  };

  services.calibre-server = {
    enable = false;
    libraryDir = "/spool/storage/calibre-library";
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

  services.restic.server = {
    enable = true;
    listenAddress = ":9004";
    dataDir = "/spool/backups/restic";
    prometheus = true;
  };

  services.nginx = {
    enable = true;
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
      proxyPass = "http://192.168.178.123:32400";
    };
  };

  services.nginx.virtualHosts."homeassistant.hormonal.party" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.178.123:8123";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };

  services.nginx.virtualHosts."goproxy.hormonal.party" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.178.123:30001";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  services.nginx.virtualHosts."backups.terrible.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9004";
      extraConfig = ''
        client_max_body_size 3G;
      '';
    };
  };

  services.nginx.virtualHosts."nixcache.infra.terrible.systems" = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:${toString config.services.nix-serve.port};
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
    package = pkgs.samba4.override {
      enableLDAP = true;
      enablePrinting = true;
      enableMDNS = true;
      enableDomainController = true;
      enableRegedit = true;
    };
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
        "create mask" = "0660";
        "directory mask" = "0755";
      };
      media = {
        path = "/spool/storage/media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0755";
      };
      danielle = {
        path = "/spool/home/danielle";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0600";
        "directory mask" = "0700";
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
  system.stateVersion = "20.03"; # Did you read the comment?
}
