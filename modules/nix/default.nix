{ config, lib, pkgs, ... }:


{
  nix = {
    settings = {
      sandbox = true;
      trusted-users = [ "@wheel" ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # substituters = [
      #   "https://nixcache.infra.terrible.systems/"
      # ];
      # trusted-substituters = [
      #   "https://nixcache.infra.terrible.systems/"
      # ];
      # trusted-public-keys = [
      #   "nixcache.infra.terrible.systems:BXjTXh35v6pyOf6kjkhd2T2Z1hXrCa4j/64HCwbZ5Mw="
      # ];
    };
  };

  system.extraSystemBuilderCmds = ''
    ln -s ${lib.cleanSource ../..} $out/systems
  '';
}
