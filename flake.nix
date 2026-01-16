{
  description = "Flake for dotfiles including NixOS and home-manager configuration";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = [ ./modules ]; };

  inputs = {
    disko.url = "github:nix-community/disko";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    golf-vim = {
      flake = false;
      url = "github:vuciv/golf";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.follows = "nixpkgs";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    one-small-step-for-vimkind = {
      flake = false;
      url = "github:jbyuki/one-small-step-for-vimkind";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };
}
