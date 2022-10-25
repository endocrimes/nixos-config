{ stdenv, config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    unzip
    lsof
    zsh
    htop
  ] ++ lib.optionals (pkgs.stdenv.isLinux) [
    lm_sensors
  ];

  services.gpg-agent = {
    enable = pkgs.stdenv.isLinux;

    # Cache Keys for 30 mins
    defaultCacheTtl = 1800; # Cache GPG Keys for 30 mins
    defaultCacheTtlSsh = 1800; # Cache GPG-SSH Keys for 30 mins

    # Require a key entry every two hours even if they've been used recently.
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 7200;

    enableSshSupport = true;
  };
}
