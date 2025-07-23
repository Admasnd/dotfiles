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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private-dotfiles.url = "git+file:///home/antwane/dev/private-dotfiles";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    diskoConfigurations = {
      nixframe = inputs.disko.lib.evalDisko {
        modules = [
          ./nixos/nixframe/nixframe-disko.nix
        ];
      };
    };
    nixosConfigurations = {
      nixframe = lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/nixframe/configuration.nix
          inputs.private-dotfiles.nixosModules.tailscale
          inputs.private-dotfiles.nixosModules.backup
          inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.antwane = ./home-manager/home.nix;
            home-manager.extraSpecialArgs = inputs;
          }
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
      iso = lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
          ./nixos/iso/configuration.nix
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
    checks.x86_64-linux = {
      home-manager = self.homeConfigurations.antwane.activationPackage;
    };
  };
}
