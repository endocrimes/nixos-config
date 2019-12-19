{ config, pkgs, ... }:

{
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
