{
  flake.modules.nixos.tailscale =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.admasnd.dotfiles.tailscale;
      inherit (lib.types) listOf str;
      inherit (lib) mkEnableOption mkIf mkOption;
    in
    {
      options.admasnd.dotfiles.tailscale = {
        enable = mkEnableOption "tailscale";
        bootstrapNS = mkOption {
          type = listOf str;
          description = ''
            At least one ip address for a nameserver needed to bootstrap Tailscale Magic DNS.

            This option appends to `networking.nameservers`.
            The default value is a Mullvad Nameserver.
          '';
          default = [ "194.242.2.4" ];
        };
        tailnet = mkOption {
          type = str;
          description = ''
            The name of your tailnet in order to use Magic DNS.

            This option appends to `networking.search`.
          '';
          example = "tailxyz.ts.net";
          default = null;
        };
      };
      config = mkIf cfg.enable {
        services.tailscale = {
          enable = lib.mkDefault true;
          # Need for using exit nodes
          useRoutingFeatures = lib.mkDefault "client";
        };
        networking.nameservers = lib.mkDefault ([ "100.100.100.100" ] ++ cfg.bootstrapNS);
        networking.search = lib.mkDefault [ cfg.tailnet ];
        networking.firewall = {
          # workaround internet access issue while using an exit node
          checkReversePath = lib.mkDefault "loose";

          # always allow traffic from your Tailscale network
          trustedInterfaces = lib.mkDefault [ "tailscale0" ];

          # allow the Tailscale UDP port through the firewall
          allowedUDPPorts = lib.mkDefault [ config.services.tailscale.port ];

          # let you SSH in over the public internet
          allowedTCPPorts = lib.mkDefault [ 22 ];
        };
        # make the tailscale command usable to users
        environment.systemPackages = lib.mkDefault [ pkgs.tailscale ];
      };
    };
}
