{ pkgs, lib, isGUISystem, ... }:

{
  home.packages = with pkgs; lib.optionals (isGUISystem) [ slack zoom-us ];
}

