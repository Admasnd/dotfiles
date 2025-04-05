{
  description = "Flake for dotfiles including NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager  = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{self, nixpkgs, nixpkgs-stable, nixos-hardware, home-manager, ... }:
    let system = "x86_64-linux";
	lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      nixframe = lib.nixosSystem {
	inherit system;
	modules = [
	  ./configuration.nix
	  nixos-hardware.nixosModules.framework-11th-gen-intel
          inputs.sops-nix.nixosModules.sops
          ({config, ...}:
          { 
            system.configurationRevision = self.rev or "dirty"; 
            sops.defaultSopsFile = ./secrets/secrets.yaml;
            sops.defaultSopsFormat = "yaml";
	    sops.age.keyFile = "/home/antwane/.config/sops/age/keys.txt";
            sops.secrets.borgbase_pass = {};
          })
	];
	specialArgs = { inherit inputs; };
      };
    };
  };
}
