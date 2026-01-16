{
  flake.modules.nixos.udev =
    { pkgs, ... }:
    {

      # add ZSA keyboard related udev rules
      services.udev.packages = [
        (pkgs.concatTextFile {
          name = "zsa-udev";
          files = [ ./50-zsa.rules ];
          destination = "/lib/udev/rules.d/50-zsa.rules";
        })
        (pkgs.concatTextFile {
          name = "svalboard-udev";
          files = [ ./59-vial.rules ];
          destination = "/lib/udev/rules.d/59-vial.rules";
        })
      ];
    };
}
