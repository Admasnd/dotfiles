{
    flake.nixosModules.laptop = {
          services.kanata = {
            enable = true;
            keyboards.framework.configFile = ./laptop.kbd;
          };
    };
}
