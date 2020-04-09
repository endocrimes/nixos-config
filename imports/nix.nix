{ config, pkgs, ... }:

{
  nix = {
    nixPath = [
      "nixos-config=/home/system/${config.networking.hostName}/configuration.nix"

      # Specify nixpkgs and unstable as the same repo for legacy raisins (aka
      # everything is unstable now)
      "nixpkgs=/home/danielle/dev/src/github.com/nixos/nixpkgs"
      "unstable=/home/danielle/dev/src/github.com/nixos/nixpkgs"

      "endopkgs=/home/danielle/dev/src/github.com/endocrimes/endopkgs"

      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    trustedUsers = [ "@wheel" ];

    useSandbox = true;
    extraOptions = ''
      auto-optimise-store = true
      builders-use-substitutes = true
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
