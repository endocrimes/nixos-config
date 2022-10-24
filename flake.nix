{
  description = "NixOS systems and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      (final: prev: {
        docker = prev.docker.override { buildxSupport = true; };
      })
    ];

    sshPublicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3bsRW8tLBO3PmpXPrpE635Zu7qOWgWvDRrTm2QQh8Z"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINx6NhFAcuwyR3ralO+ikopApVQieJtXHieLkQlQN/dn"
    ];
  in {
    nixosConfigurations.mir = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ({ pkgs, ... }: {
          imports = [
            ./hosts/mir/configuration.nix
          ];

          nix.registry.nixpkgs.flake = nixpkgs;
          nix.nixPath = ["nixpkgs=${nixpkgs}"];

          networking.useDHCP = false;
          networking.networkmanager.enable = true;

          boot.initrd.network.ssh.authorizedKeys = sshPublicKeys;

          nixpkgs.config = {
            packageOverrides = pkgs: {
              docker = pkgs.docker.override { buildxSupport = true; };
            };
          };
        })

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.danielle = import ./users/danielle/home-manager.nix;
        }

        {
          config._module.args = {
            currentSystemName = "mir";
            isGUISystem = true;
          };
        }
      ];
    };
  };
}

