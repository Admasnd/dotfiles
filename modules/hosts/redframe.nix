{
  config,
  inputs,
  ...
}:
{
  flake.nixosModules.redframe = {
    imports = [
      config.flake.nixosModules.base
      config.flake.nixosModules.gaming
      config.flake.nixosModules.laptop
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ];

    boot.kernelModules = [
      "kvm-amd"
    ];

    networking.hostName = "redframe"; # Define your hostname.

    swapDevices = [
      {
        device = "/.swapvol/swapfile";
        size = 64 * 1024;
      }
    ];

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_2TB_25443A804780";
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
                  enrollFido2 = true;
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
                        swap.swapfile.size = "64G";
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
