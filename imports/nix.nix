{ config, pkgs, ... }:

{
  nix = {
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/home/danielle/.config/system/${config.networking.hostName}/configuration.nix"
      "unstable=/home/danielle/dev/src/github.com/nixos/nixpkgs"
      "endopkgs=/home/danielle/dev/src/github.com/endocrimes/endopkgs"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    useSandbox = true;
    extraOptions = ''
      auto-optimise-store = true
    '';
  };
}
