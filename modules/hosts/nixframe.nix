{
  config,
  inputs,
  ...
}:
let
  topConfig = config;
in
{
  flake.modules.nixos.nixframe =
    {
      config,
      ...
    }:
    {
      imports = [
        topConfig.flake.modules.nixos.laptop
        inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
      ];

      admasnd.dotfiles = {
        backup = {
          paths = [
            "/home/antwane"
            "/var/lib/nostr-rs-relay"
          ];
          exclude = [
            "*/Downloads"
            "*/result"
            "*/target"
          ];
          remotePrivateKeyPath = "/home/antwane/.ssh/id_borgbase";
          localRepo = "/run/media/antwane/FRAME-USB/borg";
          localRepoMount = "run-media-antwane-FRAME\\x2dUSB.mount";
          startAt = "hourly";
        };
      };

      networking.hostName = "nixframe"; # Define your hostname.

      hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-WD_BLACK_SN750_SE_500GB_21243B802086";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "1G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "crypted";
                    settings = {
                      allowDiscards = true;
                      bypassWorkqueues = true;
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "root" = {
                          mountpoint = "/";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "home" = {
                          mountpoint = "/home";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "nix" = {
                          mountpoint = "/nix";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "swap" = {
                          mountpoint = "/.swapvol";
                          swap.swapfile.size = "32G";
                          mountOptions = [
                            "nodatacow"
                          ];
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
