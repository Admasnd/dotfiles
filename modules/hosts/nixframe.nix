{
  config,
  inputs,
  ...
}:
let
  topConfig = config;
in
{
  flake.modules.homeManager.nixframe =
    {
      pkgs,
      lib,
      ...
    }:
    {
      # enables (un)loading environment variables by changing directories
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        # enables nix devshells to be auto loaded from flakes
        nix-direnv.enable = true;
      };
      # let home-manager manage bash
      programs.bash = {
        enable = true;
        enableCompletion = true;
        shellAliases = {
          ns = "sudo nixos-rebuild --flake . switch --max-jobs auto";
          nb = "nixos-rebuild --flake . build --max-jobs auto";
          hs = "home-manager --flake . switch --max-jobs auto";
          hb = "home-manager --flake . build --max-jobs auto";
          ll = "ls -la";
          fu = "nix flake update";
        };
        bashrcExtra = ''
          . <( tailscale completion bash )
          . <(zoxide init bash) 
        '';
      };

      # for bash vi editing mode and also other tools that use readline
      programs.readline = {
        enable = true;
        extraConfig = ''
          # Enable vi editing mode
          set editing-mode vi

          # Show current mode in prompt
          set show-mode-in-prompt on

          # Customize mode indicators (optional)
          set vi-ins-mode-string "\1\e[34;1m\2[I]\1\e[0m\2 "
          set vi-cmd-mode-string "\1\e[33;1m\2[N]\1\e[0m\2 "
        '';
      };

      home.username = "antwane";
      home.homeDirectory = "/home/antwane";

      home.packages = with pkgs; [
        # security tools
        bitwarden-desktop
        sops
        mullvad-browser
        signal-desktop-bin
        # web tools
        brave
        tor-browser
        thunderbird
        protonmail-bridge
        # writing tools
        libreoffice
        # misc tools
        findutils
        unzip
        ripgrep
        evtest # for keyboard input testing
        evince
        fzf
        age
        vorta
        vlc
        jq
        zoxide # cd alternative
        yazi # file manager tui
        fd # find replacement
        ghostty
        # programming
        tmux
        nodejs
        radicle-node
        moonlight-qt
        typst
        radicle-node
        vial
      ];

      home.sessionVariables = {
        # SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
        TYPST_PACKAGE_PATH = lib.makeSearchPath "share/typst/packages" [
          pkgs.typstPackages.brilliant-cv
          pkgs.typstPackages.touying
          pkgs.typstPackages.numbly
        ];
      };

      # auto configure fonts installed via packages
      fonts.fontconfig.enable = true;

      home.stateVersion = "23.05";
    };

  flake.modules.nixos.nixframe =
    {
      config,
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = with topConfig.flake.modules.nixos; [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
        backup
        base
        devenv
        gaming
        udev
        kanata
        sops
        power
        tailscale
        yubikey
      ];

      admasnd.dotfiles = {
        backup = {
          paths = "/home/antwane";
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
        gaming.steam = {
          enable = true;
          gameModeUser = "antwane";
        };
      };

      services.printing = {
        enable = true;
        drivers = [
          pkgs.samsung-unified-linux-driver
          pkgs.brlaser
        ];
      };

      swapDevices = [
        {
          device = "/.swapvol/swapfile";
          size = 32 * 1024;
        }
      ];

      networking.hostName = "nixframe"; # Define your hostname.

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.groups.uinput = { };
      users.groups.plugdev = { };
      users.users.antwane = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "input"
          "uinput"
          "plugdev"
          "cdrom"
        ];
      };

      environment.systemPackages = with pkgs; [
        # tools for using lazy plugin manager for neovim
        clang
        # tools for using vterm with emacs
        cmake
        gnumake
        libtool
        # for Japanese input
        # ibus-engines.mozc
        ntfs3g
        home-manager
        xclip
        fw-ectool
      ];

      # installs framework laptop firmware manager
      # to update firmware, run: sudo fwupdmgr update
      services.fwupd.enable = true;

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        liberation_ttf
        fira-code
        fira-code-symbols
        carlito
        dejavu_fonts
        ipafont
        kochi-substitute
        source-code-pro
        ttf_bitstream_vera
        roboto
        source-sans-pro
        source-sans
        font-awesome
        nerd-fonts.hack
      ];

      # Enable the GNOME Desktop Environment.
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "uas"
        "usb_storage"
        "sd_mod"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "sg" # Needed for blueray drive to work with makemkv
      ];

      nixpkgs.hostPlatform = "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      };

      virtualisation.vmVariant = {
        disko.devices.disk.main = {
          device = "/dev/vda";
          passwordFile = pkgs.writeText "vm-luks-password" "\n";
        };
        boot.initrd.luks.devices.crypted = {
          device = "/dev/vda";
          tryEmptyPassphrase = true;
          passwordFile = pkgs.writeText "vm-luks-password" "\n";
        };
      };

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
