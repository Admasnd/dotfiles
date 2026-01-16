{
  flake.modules.nixos.vm =
    { config, lib, ... }:
    let
      cfg = config.admasnd.dotfiles.vm;
      inherit (lib) mkEnableOption mkOption;
      inherit (lib.types) ints port;
      inherit (lib.attrsets) mapAttrs;
    in
    {
      options.admasnd.dotfiles.vm = {
        enable = mkEnableOption "vm";
        cores = mkOption {
          type = ints.positive;
          description = ''
            The number of cores to use for the vm when using nixos-rebuild build-vm.

            This option corresponds to setting virtualization.vmVariant.virtualisation.cores.
            You can determine how many cores you have with `lscpu`.
          '';
          default = 1;
        };
        memorySize = mkOption {
          type = ints.positive;
          description = ''
            The amount of memory in MiB (Mebibyte or base 2 mega bytes) to use for the vm when using nixos-rebuild build-vm.

            This option corresponds to setting virtualization.vmVariant.virtualisation.memorySize.
            You can determine how much RAM you have with `free -h`.
          '';
          default = 1024;
        };
        vmPort = lib.mkOption {
          type = port;
          description = ''
            The port to use to connect to the qemu VM via SPICE.

            This port will be opened in the system firewall only for the tailscale interface so
            that only members of the tailnet can connect to it.

          '';
          default = 5930;
        };

      };
      config = lib.mkIf (config.admasnd.dotfiles.tailscale.enable && cfg.enable) {
        # for the system when using nixos-rebuild build-vm
        virtualisation.vmVariant = {
          users.users = mapAttrs config.users.users (user: _: { hashedPassword = ""; });
          # enable SPICE guest agent in VM
          # this helps with input device forwarding
          # also helps with display resizing to match connecting client
          services.spice-vdagentd.enable = true;
          # helps with coordination between VM and host
          services.qemuGuest.enable = true;

          virtualisation = {
            inherit (cfg) cores memorySize;
            qemu = {
              # disable-ticketing disables password authentication for
              # SPICE connection but we will be using ssh for securing connection
              options = [
                "-spice port=${builtins.toString cfg.vmPort},addr=0.0.0.0,disable-ticketing=on"
              ];
            };

          };
        };
        # open port needed to communicate with VM only for tailscale interface
        networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ cfg.vmPort ];
      };
    };
}
