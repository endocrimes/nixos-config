{ config, pkgs, ... }:

{
  nix = {
    nixPath = [
      "nixpkgs=/home/system/submodules/nixpkgs"
      "nixos-config=/home/system/hosts/${config.networking.hostName}/configuration.nix"
      "endopkgs=/home/system/submodules/endopkgs"
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
