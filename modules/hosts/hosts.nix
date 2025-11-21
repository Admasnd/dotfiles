{
  lib,
  self,
  ...
}:
{
  # Setting up aspects for hosts which can be referred to via den.aspects.<host>
  den.hosts.x86_64-linux.nixframe.description = "Framework 13 inch 11th gen intel laptop";
  den.hosts.x86_64-linux.nixjoy.description = "AMD based gaming desktop";
  den.hosts.x86_64-linux.iso.description = "installer iso image";

  # Adding checks to build each host
  perSystem = {
    checks = lib.genAttrs (builtins.attrNames self.nixosConfigurations) (
      host: self.nixosConfigurations.${host}.config.system.build.toplevel
    );
  };

}
