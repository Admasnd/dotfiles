{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.laptop = moduleWithSystem (
  perSystem@{ inputs', ...}:
  nixos@{ pkgs, ... }: {
    environment.systemPackages = [
      (inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = inputs'.nixpkgs-stable.legacyPackages.papis;
        flags."-c" = ./config;
      })
    ];
  });
}
