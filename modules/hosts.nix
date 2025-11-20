{
  lib,
  inputs,
  self,
  ...
}:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations = {
    nixframe = lib.nixosSystem {
      inherit system;
      modules = [
        ../hosts/nixframe/configuration.nix
        inputs.private-dotfiles.nixosModules.tailscale
        inputs.private-dotfiles.nixosModules.backup
        inputs.private-dotfiles.nixosModules.pam
        inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
        inputs.disko.nixosModules.disko
        ../hosts/nixframe/nixframe-disko.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.antwane = ../hosts/nixframe/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
      specialArgs = { inherit inputs; };
    };
    nixjoy = lib.nixosSystem {
      inherit system;
      modules = [
        ../hosts/nixjoy/configuration.nix
        inputs.private-dotfiles.nixosModules.tailscale
      ];
    };
    iso = lib.nixosSystem {
      inherit system;
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
        ../hosts/iso/configuration.nix
      ];
    };
  };
  perSystem = {
    checks = lib.genAttrs (builtins.attrNames self.nixosConfigurations) (
      host: self.nixosConfigurations.${host}.config.system.build.toplevel
    );
  };

}
