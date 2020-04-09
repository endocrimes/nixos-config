{ config, pkgs, ... }:

{
  nix = {
    extraOptions = ''
      post-build-hook = /etc/nix/copy-to-cache.sh
    '';

    buildMachines = [
      {
        hostName = "mir.local";
        system = "x86_64-linux";
        maxJobs = 12;
        speedFactor = 24;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "salzburg.local";
        system = "x86_64-linux";
        maxJobs = 2;
        speedFactor = 8;
        supportedFeatures = [ "benchmark" "big-parallel" ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "berlin.infra.hormonal.party";
        system = "x86_64-linux";
        maxJobs = 6;
        speedFactor = 12;
        supportedFeatures = [ "nixos-tests" "benchmark" "big-parallel" ];
        mandatoryFeatures = [ ];
      }
    ];

    distributedBuilds = true;
  };
}
