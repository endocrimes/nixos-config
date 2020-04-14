{ config, pkgs, lib, ... }:
{
  imports = [
    ../nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  time.timeZone = lib.mkDefault "Europe/Berlin";

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
    nssmdns = true;
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
    telnet
    nmap
    lm_sensors
  ];
  programs.mtr.enable = true;
  services.openssh.enable = true;
}
