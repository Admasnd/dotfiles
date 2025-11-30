{
  den.aspects.gaming = _: {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        config =
          lib.mkIf (config.gaming.remotePlay.enable && config.gaming.remotePlay.server == "sunshine")
            {
              services.sunshine = {
                capSysAdmin = true;
                enable = true;
                applications = {
                  apps = [
                    {
                      name = "TV";
                      prep-cmd = [
                        {
                          do = "sh -c \"${pkgs.mutter}/bin/gdctl set -L -M DP-3 -p -m 3840x2160@59.997 -c bt2100\"";
                          undo = "sh -c \"${pkgs.mutter}/bin/gdctl set -L -M DP-3 -p -m 3840x2160@240.084 -c bt2100\"";
                        }
                      ];
                      detached = [
                        "${pkgs.libcap}/bin/capsh --delamb=cap_sys_admin -- -c \"${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/gamepadui\""
                      ];
                      image-path = "steam.png";
                    }
                    {
                      name = "Laptop";
                      prep-cmd = [
                        {
                          do = "sh -c \"${pkgs.mutter}/bin/gdctl set -L -M DP-3 -p -m 2048x1152@59.909 -c bt2100\"";
                          undo = "sh -c \"${pkgs.mutter}/bin/gdctl set -L -M DP-3 -p -m 3840x2160@240.084 -c bt2100\"";
                        }
                      ];
                      detached = [
                        "${pkgs.libcap}/bin/capsh --delamb=cap_sys_admin -- -c \"${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/gamepadui\""
                      ];
                      image-path = "steam.png";
                      output = "/tmp/sunshine-steam-big-picture-log.txt";
                    }
                    {
                      name = "Steam Deck";
                      prep-cmd = [
                        {
                          do = "sh -c \"${pkgs.mutter}/bin/gdctl set -L -M DP-3 -p -m 1280x800@59.910 -c bt2100\"";
                          undo = "sh -c \"${pkgs.mutter}/bin/gdctl set -L -M DP-3 -p -m 3840x2160@240.084 -c bt2100\"";
                        }
                      ];
                      detached = [
                        "${pkgs.libcap}/bin/capsh --delamb=cap_sys_admin -- -c \"${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/gamepadui\""
                      ];
                      image-path = "steam.png";
                      output = "/tmp/sunshine-steam-big-picture-log.txt";
                    }
                  ];
                };

              };

              # This is needed for sunshine service
              networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
                47984
                47989
                47990
                48010
              ];
              networking.firewall.interfaces."tailscale0".allowedUDPPorts = [
                47998
                47999
                48000
                48002
                48010
              ];
            };
      };
  };
}
