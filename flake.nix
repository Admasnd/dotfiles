{
  description = "Flake for dotfiles including NixOS and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private-dotfiles.url = "git+file:///home/antwane/dev/private-dotfiles";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    overlays = [
      (final: prev: {
        linux-firmware = prev.linux-firmware.overrideAttrs (old: rec {
          version = "20250509";
          src = prev.fetchzip {
            url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz";
            hash = "sha256-0FrhgJQyCeRCa3s0vu8UOoN0ZgVCahTQsSH0o6G6hhY=";
          };
        });
      })
    ];
  in {
    nixosConfigurations = {
      nixframe = lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/nixframe/configuration.nix
          inputs.private-dotfiles.nixosModules.tailscale
          inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.antwane = ./home-manager/home.nix;
            home-manager.extraSpecialArgs = inputs;
          }
          ({config, ...}: {
            system.configurationRevision = self.rev or "dirty";
            sops.defaultSopsFile = ./secrets/secrets.yaml;
            sops.defaultSopsFormat = "yaml";
            sops.age.keyFile = "/home/antwane/.config/sops/age/keys.txt";
            sops.secrets.borgbase_pass = {};
          })
        ];
        specialArgs = {inherit inputs;};
      };
      nixjoy = lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/nixjoy/configuration.nix
          inputs.private-dotfiles.nixosModules.tailscale
          # Override sunshine service with my fork
          ({...}: {
            nixpkgs.overlays = overlays;
            # disabledModules = ["services/networking/sunshine.nix"];
            # imports = [
            #   "${inputs.nixpkgs-sunshine}/nixos/modules/services/networking/sunshine.nix"
            # ];
          })
        ];
      };
    };
    homeConfigurations = {
      antwane = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };

        modules = [
          ./home-manager/home.nix
        ];
        extraSpecialArgs = inputs;
      };
    };
  };
}
