{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../imports/defaults.nix
      ../imports/server.nix
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
    22 80 443
    8080 # calibre
    445 139 # samba
  ];
  networking.firewall.allowedUDPPorts = [
    137 138 # samba
  ];
  networking.firewall.allowPing = true;

  virtualisation.docker.enable = true;

  users.users.danielle = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "dialout" ];
    shell = pkgs.zsh;
    hashedPassword = builtins.readFile ./passwd-danielle;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDy6nsIHNmq0zzkXbjutADn2cjOoLjz70+yQPnDku9Da/BdmjQEoArsojI/l5WuP0D2+xUXEOLQonGF1LKdBiBrCn775PVF/wd4MlW1a7uyXiFlYu4a2H8dgaQ79E85/Tpzc9AwzkVb+vq1oii49yQFarc7RHrqXikQ9yDTqWZQ5BYZUSXZVZ+ZCct9Y/3xxQyMD7i1eTaf7t2HfIUusAVzIXfpUfFQ2XxUyoJtRrG2hgTIdUikN0+JDD8Th1d+rPIw+uYNwbrw9qEpMY8MXT4Od8i7/j8Wwyo4iOF04n2nNmV+p1ToQ6iiduZZZ3/npRdhzbgXJK5TNq98R66Igiit" # mew
    ];
  };

  users.users.maxine = {
   isNormalUser = true;
   shell = pkgs.zsh;
   openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlFfgtoQztJ1Z+VOXXnS11rJfYfXM3dXevgyMUX3TIWTk2Wj3IVAuZdiggOAviDEARbGhdF9S/chyTr6+TYarFDE/iPmuXv5L53DFijYVq90q5mRnhZWraWEN3S298QP+Y1DSHcd6WdoAId2vhwN2br1rQGSJO216rjRD3EM7ytbou+f75iAysbmkfG1CXlZaklzzgaiwjNpAErL5mpMcRV0+IMqf3hIuZuVfn0NujRNtIY6haSUOAdFnNHIdW/oG3jKPdCl+ecELwgyzyn78m+iyIeio8SbQUxOQr1GH+x7dx03vGR33bUkyn/H9JLtfMDhY2MR6SQ8R3ZqfSFKK5+OAXZ8Ry5+EiyhJ85fEyabR9nxcw7ooiAgbHPruByYPgPI6tJBnsj7HBUFa7Yf3FxuZAlF+BRyaxtYRcgG1Moe5AMrjchzwit1ydSCT6ZnFJCuFLRb072V9+wlzoILebkK9P6RKDnTaazgDGJ02603IXey1CMgwJAky7Ue9R1dy4Nabpn5ROC67x3JyzD7nlksqrRzOxetTawkXTDL3IicYWpmBgTwXHN9x4fDixYEeHhvbif8W8/B4rxpdMKoqSZGAyEMGn3YGlF+OuuhoikSY6JQTap9fwC9kPXzcjOmTuOa42CSoruEj/MFHjYUG0j934SeQveMEB/n0c/YoE8w=="
       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcUKgJhLwoktrwbTyPa5jOpCrw3GqXCu0DZvwMEWTmJWthd89DR5z+L2PRU2cUTssG2fcHfakbKkhPGo+Zf6DZEgQ6xyccgIxp+Zb59zqe35BkwSROxtxbc/L547kQKyPag9CkN98+DSyn82Q1GKBctqHlTnOzSj0MW/pAzIabb02oApND/b0lYqONVI9NQ7SxNSndOBnasDp5d8ryDMgQOzsiWUrH3CMWqOUV9lU3rVfcR86Z7s94QMUVH8i8nxHmIRQfkkpgAmqp78jmLKgaxLHtE2ZfNnpUknNETNExvx/qG7cAmU303EsHPy7tWsuVVlimDuP6VWvQkgqzSKtKx/PNE1upbB4RLQOzuFYTbz6dob7X2TgqaZrcKZsRBjjn3p/4VOYvDjsD14ocSGpl91lXsqgOyn30G6y9Una50cmUcgv+Ew75jHvOEiLXdXKd9z9+Inul+9mrshLl0nJ9SeNrRo9Kz2vOWqS/oJXDPLQAo0hysl/6tlIDr52b3rzEBhkM6L5gorYPovfa+0yWMm03yLtoUWT+SRglZ7Ig9cYhZdZVLY5pyCvg8ndSK8yxZBbYFsC4gATb24ebS7Bv3hcNMnI9ZN3lDuyv+hM8Y8lW7Nq+D8en0uEtpnKFR03ZSGvtmgNZDwaRWW9eUwPZwtXGDOiFZMInZpAoGTWc5w=="
       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkixqrZH3z2dIHUV5EicK3t/Wq1H3puB81CUHd87cyOhmP9EHEfDOm5yZwwyA2awKwpGL5HXdRcZ9RPkHAB1W9XN8QbhssID11mhCjJHCVK92SDAvRRQ17nsI1BxG1Qp3hfFB8VvFA9DT228YTlJoVg19UmKIea1jg0ddruN2qPgb3WzvS0BAQ9CxK+CUeWEvWq7WTfVsQvqzsgbIE6H8nYyJVoj3dcpxqr8M3iBqNLDKhc9SG2jvScWOIqY9VsscS3HEUQ+zysYc5LEoJ8rK0mUh0ODfz2shTu+Ajhq99RmotITEKgQhxeLwSD4ThU0WYvQDVl+66Mcr28xksV0uMo7AQFIwY4Fb0x69lualcHt71bDP5Yzw961CJyXz5fFE9T/9ktfjxvKve8W+i8It3xqM/isIYO+WnyPCESpGkIUvz48IE2IUO8wM1rS6zbIDsMd1P1Y24m80GuTI9vvnFDfNWwgYHnbpsD8F+lFvidIDm2xWaXK0GfSMOIhbxrIle6po0nQhdNuGh59ZiOuHNPM2MUjmeIzG1Fj7A4L5OCJSrkJ3utRY78oAeoKmE+T6h4KxGxl6tKGk2Vy56R6RQl/QFSf7jFsUR+7AxdM50WxS3u7ckT3Fcw8xxSqHvSxPuiHQhkL6jpltmcYbUz7CMLQ4o99XR66mFMUGTMRCRMQ=="
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
