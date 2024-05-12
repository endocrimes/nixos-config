{ config, pkgs, lib, ... }:

{
  imports = [
    ../nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  time.timeZone = lib.mkDefault "Europe/Berlin";

  environment.wordlist.enable = true;

  environment.shells = [ pkgs.zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.fish = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    ipv4 =  true;
    ipv6 = true;
    nssmdns4 = true;
  };

  # Minimal tools required for running a machine
  environment.systemPackages = with pkgs; [
    git
    tmux
    vim
    wget
    jq
    htop
    dnsutils
    lsof
    inetutils
    nmap
    lm_sensors
    rsync
    iotop
    pciutils
    usbutils
  ];
  programs.mtr.enable = true;
  services.openssh.enable = true;

  # Mosh
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  security.wrappers = {
    utempter = {
      source = "${pkgs.libutempter}/lib/utempter/utempter";
      owner = "nobody";
      group = "utmp";
      setuid = false;
      setgid = true;
    };
  };
}
