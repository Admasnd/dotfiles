{ inputs, ... }:
{
  den.aspects.papis.homeManager = {
    home.packages = [
      inputs.nixpkgs-stable.legacyPackages.x86_64-linux.papis
    ];
    xdg.configFile."papis/config".source = ./config;
  };
}
