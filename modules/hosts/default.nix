{
  config,
  flake-parts-lib,
  lib,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
  hosts = [
    "iso"
    "nixframe"
    "nixjoy"
  ];
  dotfilesLib = {
    genHostsWithChecks =
      { hosts }:
      {
        # Adding host definitions using their corresponding modules
        flake.nixosConfigurations = lib.genAttrs hosts (
          host:
          lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              config.flake.modules.nixos.${host}
            ];
          }
        );
        # Adding checks to build each host
        perSystem = {
          checks = lib.genAttrs (builtins.attrNames config.flake.nixosConfigurations) (
            host: config.flake.nixosConfigurations.${host}.config.system.build.toplevel
          );
        };
      };
  };
in
{
  imports = [
    ./base.nix
    ./iso.nix
    ./nixframe.nix
    ./nixjoy.nix
    # (importApply dotfilesLib.genHostsWithChecks { inherit hosts; })
  ];

  # output library
  # flake.lib = dotfilesLib;

  # Adding host definitions using their corresponding modules
  flake.nixosConfigurations = lib.genAttrs hosts (
    host:
    lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        config.flake.modules.nixos.${host}
      ];
    }
  );

  # Adding checks to build each host
  perSystem = {
    checks = lib.genAttrs (builtins.attrNames config.flake.nixosConfigurations) (
      host: config.flake.nixosConfigurations.${host}.config.system.build.toplevel
    );
  };
}
