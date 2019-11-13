{ config, pkgs, ... }:

{
  # Must configure perf_event_paranoid to allow the node exporter to pull useful
  # metrics from the system.
  boot.kernel.sysctl = {
     "kernel.perf_event_paranoid" = lib.mkOverride 50 0;
  };

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
  };

}
