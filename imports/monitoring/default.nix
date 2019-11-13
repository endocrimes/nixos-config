{ config, pkgs, ... }:

{
  imports = [
    ./prometheus-node-exporter.nix
  ];
}
