{
  config,
  lib,
  ...
}:
let
  hosts = [
    "iso"
    "nixframe"
    "redframe"
    "nixjoy"
  ];
in
{
  imports = [
    ./base.nix
    ./iso.nix
    ./nixframe.nix
    ./redframe.nix
    ./nixjoy.nix
  ];

  # Adding host definitions using their corresponding modules
  flake.nixosConfigurations = lib.genAttrs hosts (
    host:
    lib.nixosSystem {
      modules = [
        config.flake.modules.nixos.${host}
        {
          nixpkgs.hostPlatform = "x86_64-linux";
        }
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
