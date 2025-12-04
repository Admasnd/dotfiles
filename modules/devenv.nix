{
  den.aspects.devenv = {
    nixos = {
      nix.extraOptions = ''
        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      '';
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          devenv
        ];
      };
  };
}
