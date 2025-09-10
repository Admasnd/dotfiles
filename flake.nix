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
  in {
    nixosConfigurations = {
      nixframe = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixframe/configuration.nix
          inputs.private-dotfiles.nixosModules.tailscale
          inputs.private-dotfiles.nixosModules.backup
          inputs.private-dotfiles.nixosModules.pam
          inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
          inputs.disko.nixosModules.disko
          ./hosts/nixframe/nixframe-disko.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.antwane = ./hosts/nixframe/home.nix;
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
      };
      nixjoy = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixjoy/configuration.nix
          inputs.private-dotfiles.nixosModules.tailscale
        ];
      };
      iso = lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
          ./hosts/iso/configuration.nix
        ];
      };
    };
    devShells."${system}".pentest = let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
      pkgs.mkShell {
        name = "pentest-env";

        packages = with pkgs; [
          nmap
          wireshark
          metasploit
          putty
        ];
      };
  };
}
