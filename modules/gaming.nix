{
  flake.modules.nixos.gaming =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.admasnd.dotfiles.gaming;
      inherit (lib)
        mkEnableOption
        mkIf
        mkMerge
        mkOption
        ;
      inherit (lib.types) enum str nullOr;
    in
    {
      options.admasnd.dotfiles.gaming = {
        steam = {
          enable = mkEnableOption "enable steam";
          gameModeUser = mkOption {
            type = nullOr str;
            description = "user to add to the gamemode group";
            example = "john";
            default = null;
          };
        };
        gamescope = {
          enable = mkEnableOption "enable steam gamescope as default windows manager session";
        };
        remotePlay = {
          enable = mkEnableOption "enable remote play";
          server = mkOption {
            type = enum [
              "sunshine"
              "steam"
            ];
            description = "select which program will be used to host remote play sessions";
            default = "steam";
          };
        };
      };
      config = mkMerge [
        (mkIf (cfg.gamescope.enable || cfg.remotePlay.enable) {
          admasnd.dotfiles.gaming.steam.enable = true;
        })
        (mkIf
          (
            config.admasnd.dotfiles.tailscale.enable
            && cfg.remotePlay.enable
            && cfg.remotePlay.server == "steam"
          )
          {
            networking.firewall.interfaces."tailscale0" = {
              allowedTCPPorts = [
                27036
                27037
              ];
              allowedUDPPorts = [
                27036 # peer discovery
                10400
                10401
              ];
              allowedUDPPortRanges = [
                {
                  from = 27031;
                  to = 27035;
                }
              ];
            };
          }
        )
        (mkIf cfg.gamescope.enable {
          services.displayManager.defaultSession = "steam";
          # this enables gamescope to increase priority of process for the process scheduler
          programs.gamescope.capSysNice = true;
          programs.steam.gamescopeSession.enable = true;
        })
        (mkIf cfg.steam.enable {
          assertions = [
            {
              assertion = !(builtins.isNull cfg.steam.gameModeUser);
              message = ''
                admasnd.dotfiles.steam.gameModeUser must be set when
                admasnd.dotfiles.steam.enable is true'';
            }
          ];
          programs.steam = {
            enable = true;
            package = pkgs.steam.override { extraPkgs = pkgs: with pkgs; [ mangohud ]; };
          };
          programs.gamemode.enable = true;
          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "steam-unwrapped"
              "steam"
            ];
          # Add host users to gamemode group.
          users.users.${cfg.steam.gameModeUser}.extraGroups = [
            "gamemode"
          ];
        })
      ];
    };
}
