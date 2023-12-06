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

      substituters = [
        "https://attic.fly.dev/danielle-personal"
      ];
      trusted-substituters = [
        "https://attic.fly.dev/danielle-personal"
      ];
      trusted-public-keys = [
        "danielle-personal:7S0LwNN3XpQ3IBpIyr/IVvHwIpMo9bk49JZ5LjNsPpk="
      ];
    };
  };

  system.extraSystemBuilderCmds = ''
    ln -s ${lib.cleanSource ../..} $out/systems
  '';
}
