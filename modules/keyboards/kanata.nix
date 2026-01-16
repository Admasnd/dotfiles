{
  flake.modules = {
    homeManager.kanata =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          kanata
        ];
      };
    nixos.kanata = {
      services.kanata = {
        enable = true;
        keyboards.framework.configFile = ./laptop.kbd;
      };
    };
  };
}
