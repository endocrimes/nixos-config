{ config, pkgs, lib, ... }:
{
  imports = [
    ./nix.nix
    ./minimal-ops.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  time.timeZone = lib.mkDefault "Europe/Berlin";

  environment.shells = [ pkgs.zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  ## Services

  services.avahi = {
    enable = true;
    ipv4 =  true;
    ipv6 = true;
    nssmdns = true;
  };

  ## Enable CUPS to print documents.
  services.printing.enable = true;
}
