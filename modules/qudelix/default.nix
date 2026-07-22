{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      # add Qudelix 5K related udev rules
      services.udev.packages = [
        (pkgs.concatTextFile {
          name = "qudelix-udev";
          files = [ ./99-qudelix.rules ];
          destination = "/lib/udev/rules.d/99-qudelix.rules";
        })
      ];
    };
}
