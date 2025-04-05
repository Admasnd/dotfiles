{
  description = "Flake for home-manager configuration";

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager  = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
   in {
      homeConfigurations = {
        antwane = inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = import nixpkgs { 
                  config.allowUnfree = true;
                  inherit system;
                };

	        modules = [
                  inputs.nvf.homeManagerModules.default
                  ./home.nix
	        ];
                extraSpecialArgs = inputs;
	      };
      };
    };
}
