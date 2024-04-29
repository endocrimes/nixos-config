{
  description = "NixOS systems and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-overlay = {
      url = "git+ssh://git@github.com/endocrimes/nixos-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic = {
      url = "github:zhaofengli/attic";
      # Attic gets its own copy of nixpkgs because building it is frustrating.
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nixos-overlay, attic }@inputs: let
    overlays = [
      nixos-overlay.overlays.default
      (final: prev: {
        docker = prev.docker.override { buildxSupport = true; };
        vim_configurable = prev.vim_configurable.override {
          guiSupport = (if prev.stdenv.isDarwin then "none" else "gtk3");
          darwinSupport = prev.stdenv.isDarwin;
        };
        gnupg = prev.gnupg.override {
          guiSupport = false;
        };
        polybar = prev.polybar.override {
          i3Support = true;
          pulseSupport = true;
        };
      })
    ];

    sshPublicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3bsRW8tLBO3PmpXPrpE635Zu7qOWgWvDRrTm2QQh8Z"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINx6NhFAcuwyR3ralO+ikopApVQieJtXHieLkQlQN/dn"
    ];
  in {
    homeConfigurations = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"] (system: {
      danielle_nogui = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          config.xdg.configHome = "/home/danielle/.config";
          inherit overlays system;
        };


        modules = [
          nixos-overlay.nixosModules.default
          ./users/danielle/home-manager.nix
          {
            home.username = "danielle";
            home.homeDirectory = if system == "aarch64-darwin" then "/users/danielle" else "/home/danielle";
            home.packages = [ attic.packages.${system}.default ];
          }
        ];

        extraSpecialArgs = {
          isGUISystem = false;
          isWSL2 = false;
        };
      };});

    nixosConfigurations.saturnv = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          nixos-wsl.nixosModules.wsl
          ({ pkgs, ... }: {
          imports = [
            ./hosts/saturnv/configuration.nix
          ];

          nix.registry.nixpkgs.flake = nixpkgs;
          nix.nixPath = [
            "nixpkgs=${nixpkgs}"
          ];
          environment.systemPackages = [ attic.packages."x86_64-linux".default ];

          nixpkgs.overlays = overlays;
        })

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.danielle = import ./users/danielle/home-manager.nix;
          home-manager.extraSpecialArgs = {
            isGUISystem = false;
            isWSL2 = true;
          };
        }
      ];
    };
  };
}

