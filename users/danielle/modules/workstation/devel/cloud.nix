{ pkgs, lib, ... }:

let
  endopkgs = import <endopkgs> { };
in {
  home.packages = with pkgs; [
    awscli
    google-cloud-sdk
    kind
#    endopkgs.hclfmt
  ];
}
