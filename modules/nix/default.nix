{ config, lib, pkgs, ... }:

{
  nix = {
    nixPath = [
      "nixpkgs=/home/system/submodules/nixpkgs"
      "nixos-config=/home/system/hosts/${config.networking.hostName}/configuration.nix"
      "endopkgs=/home/system/submodules/endopkgs"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    settings = {
      sandbox = true;

      trusted-users = [ "@wheel" ];

      # The copy-to-cache script can be found in scripts/copy-to-cache.sh
      auto-optimise-store = true;
      post-build-hook = "/etc/nix/copy-to-cache.sh";

      substituters = [
        "https://nixcache.infra.terrible.systems/"
      ];
      trusted-binary-caches = [
        "https://nixcache.infra.terrible.systems/"
      ];
      trusted-public-keys = [
        "nixcache.infra.terrible.systems:BXjTXh35v6pyOf6kjkhd2T2Z1hXrCa4j/64HCwbZ5Mw="
      ];
    };
  };

  system.extraSystemBuilderCmds = ''
    ln -s ${lib.cleanSource ../..} $out/systems
  '';
}
