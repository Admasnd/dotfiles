{ inputs, ... }:
{
  flake.nixosModules.laptop = { pkgs, ... }: {
    environment.systemPackages = [
      (inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.papis;
        flags."-c" = ./config;
      })
    ];
  };
}
