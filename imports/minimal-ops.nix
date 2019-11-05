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
  ];

  programs.mtr.enable = true;

  services.openssh.enable = true;
}
