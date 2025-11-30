{
  den.aspects.gaming = users: {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        config = lib.mkMerge [
          {
            networking.firewall.interfaces."tailscale0" =
              lib.mkIf (config.gaming.remotePlay.enable && config.gaming.remotePlay.server == "steam")
                {
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
          # Change default session to gamescope
          (lib.mkIf config.gaming.gamescope.enable {
            services.displayManager.defaultSession = "steam";
            # this enables gamescope to increase priority of process for the process scheduler
            programs.gamescope.capSysNice = true;
            programs.steam.gamescopeSession.enable = true;
          })
          (lib.mkIf config.gaming.steam.enable {
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
            users.users = lib.genAttrs users (user: {
              extraGroups = [
                "gamemode"
              ];
            });
          })
        ];
      };
  };
}
