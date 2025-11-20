{
  lib,
  inputs,
  self,
  ...
}:
{
  den.hosts.x86_64-linux.nixframe = {
    description = "Framework 13 inch 11th gen intel laptop";
  };
  den.hosts.x86_64-linux.nixjoy = {
    description = "AMD based gaming desktop";
  };
  den.hosts.x86_64-linux.iso = {
    description = "installer iso image";
  };
  den.aspects.nixframe.nixos = {
    imports = [
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
  };
  den.aspects.nixjoy.nixos = {
    imports = [
      ../hosts/nixjoy/configuration.nix
      inputs.private-dotfiles.nixosModules.tailscale
    ];
  };
  den.aspects.iso.nixos = {
    imports = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
      ../hosts/iso/configuration.nix
    ];
  };
  perSystem = {
    checks = lib.genAttrs (builtins.attrNames self.nixosConfigurations) (
      host: self.nixosConfigurations.${host}.config.system.build.toplevel
    );
  };

}
