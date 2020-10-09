{ config, pkgs, ... }:

{
  nix = {
    nixPath = [
      "nixpkgs=/home/danielle/dev/src/github.com/nixos/nixpkgs"
      "nixos-config=/home/system/${config.networking.hostName}/configuration.nix"
      "unstable=/home/danielle/dev/src/github.com/nixos/nixpkgs"
      "nixos-stable=/home/danielle/dev/src/github.com/nixos/nixpkgs-stable"
      "endopkgs=/home/danielle/dev/src/github.com/endocrimes/endopkgs"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    trustedUsers = [ "@wheel" ];
    useSandbox = true;

    # The copy-to-cache script can be found in scripts/copy-to-cache.sh
    extraOptions = ''
      auto-optimise-store = true
      post-build-hook = /etc/nix/copy-to-cache.sh
    '';

    binaryCaches = [
      "https://nixcache.infra.terrible.systems/"
    ];
    trustedBinaryCaches = [
      "https://nixcache.infra.terrible.systems/"
    ];
    binaryCachePublicKeys = [
      "nixcache.infra.terrible.systems:BXjTXh35v6pyOf6kjkhd2T2Z1hXrCa4j/64HCwbZ5Mw="
    ];
  };
}
