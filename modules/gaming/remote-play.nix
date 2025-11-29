{
  den.aspects.gaming.nixos = {
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
  };
}
