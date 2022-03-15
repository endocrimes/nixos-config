{ config, pkgs, ... }:

{
  nix = {
    # Use substitutes when using remote builders as they'll usually have more
    # consistent internet connections.
    extraOptions = ''
      builders-use-substitutes = true
    '';

    buildMachines = [
      {
        hostName = "berlin.infra.hormonal.party";
        system = "x86_64-linux";
        maxJobs = 12;
        speedFactor = 2;
        supportedFeatures = [ "nixos-tests" "benchmark" "big-parallel" ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "lisbon.infra.hormonal.party";
        system = "x86_64-linux";
        maxJobs = 16;
        speedFactor = 2;
        supportedFeatures = [ "nixos-tests" "benchmark" "big-parallel" ];
        mandatoryFeatures = [ ];
      }
    ];

    distributedBuilds = true;
  };
}
