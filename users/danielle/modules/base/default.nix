{ stdenv, config, pkgs, lib, isGUISystem, isWSL2, ... }:

let
wslMimeApps = {
  "text/html" = "wslview";
  "x-scheme-handler/http" = "wslview";
  "x-scheme-handler/https" = "wslview";
  "x-scheme-handler/about" = "wslview";
  "x-scheme-handler/unknown" = "wslview";
  "x-scheme-handler/file" = "wslview";
};
whenWSL = attrs: if isWSL2 then attrs else {};
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    unzip
    lsof
    zsh
    htop
    gnupg
    xdg-utils
  ] ++ lib.optionals (pkgs.stdenv.isLinux) [
    lm_sensors
  ] ++ lib.optionals (isWSL2) [
    wslu
  ];

  xdg.mimeApps = (whenWSL {
    enable = true;
    defaultApplications = wslMimeApps;
  });

  services.gpg-agent = {
    enable = pkgs.stdenv.isLinux;

    # Cache Keys for 30 mins
    defaultCacheTtl = 1800; # Cache GPG Keys for 30 mins
    defaultCacheTtlSsh = 1800; # Cache GPG-SSH Keys for 30 mins

    # Require a key entry every two hours even if they've been used recently.
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 7200;

    pinentryFlavor = "tty";

    extraConfig = ''
    allow-loopback-pinentry
    '';
  };
}
