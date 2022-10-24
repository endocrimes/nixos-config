{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    gnumake
    gotestsum
  ];

  programs.go = {
    enable = true;
    package = pkgs.go_1_17;
    goPath = lib.mkDefault "dev";
  };
}

