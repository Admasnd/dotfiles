{ inputs, ... }:
{
  flake.modules.homeManager.papis = {
    home.packages = [
      inputs.nixpkgs.legacyPackages.x86_64-linux.papis
    ];
    xdg.configFile."papis/config".source = ./config;
  };
}
