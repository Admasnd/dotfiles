{
  den.aspects.gaming = _: {
    nixos =
      { config, lib, ... }:
      {
        options = {
          gaming = {
            # freeformType = with lib.types; attrsOf submodule;
            steam = {
              enable = lib.mkEnableOption "enable steam";
            };
            gamescope = {
              enable = lib.mkEnableOption "enable steam gamescope as default windows manager session";
            };
            remotePlay = {
              enable = lib.mkEnableOption "enable remote play";
              server = lib.mkOption {
                type = lib.types.enum [
                  "sunshine"
                  "steam"
                ];
                description = "select which program will be used to host remote play sessions";
                default = "steam";
              };
            };
          };
        };
        config = {
          gaming.steam.enable = lib.mkIf (
            config.gaming.gamescope.enable || config.gaming.remotePlay.enable
          ) true;
        };
      };
  };
}
