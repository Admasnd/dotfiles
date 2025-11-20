{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];
  flake-file = {
    description = "Flake for dotfiles including NixOS and home-manager configuration";
    inputs = {
      disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      golf-vim = {
        url = "github:vuciv/golf";
        flake = false;
      };
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      one-small-step-for-vimkind = {
        url = "github:jbyuki/one-small-step-for-vimkind";
        flake = false;
      };
      private-dotfiles.url = "git+file:///home/antwane/dev/private-dotfiles";
    };
  };
}
