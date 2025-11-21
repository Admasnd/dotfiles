{
  den.aspects.keyboards = {
    _.laptop = {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            kanata
          ];
        };
      nixos = {
        services.kanata = {
          enable = true;
          keyboards.framework.configFile = ./laptop.kbd;
        };
      };
    };

    _.voyager.nixos =
      { pkgs, ... }:
      {
        # add ZSA keyboard related udev rules
        services.udev.packages = [
          (pkgs.concatTextFile {
            name = "zsa-udev";
            files = [ ./50-zsa.rules ];
            destination = "/lib/udev/rules.d/50-zsa.rules";
          })
        ];

      };
  };
}
