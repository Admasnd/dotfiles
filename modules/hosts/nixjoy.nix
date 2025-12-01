{
  inputs,
  den,
  ...
}:
{
  # TODO create a disko configuration for nixjoy and test backup and restore
  # TODO backup game saves and game data
  den.aspects.nixjoy = {
    includes = with den.aspects; [
      keyboards._.voyager
      (gaming [ "joy" ])
      vm
    ];

    nixos =
      {
        config,
        lib,
        modulesPath,
        ...
      }:
      {
        imports = [
          inputs.private-dotfiles.nixosModules.tailscale
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        gaming = {
          gamescope.enable = true;
          remotePlay.enable = true;
        };

        vm = {
          cores = 2;
          vmPort = 5930;
          memorySize = 8192;
        };

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.hostName = "nixjoy"; # Define your hostname.

        # Enable the GNOME Desktop Environment.
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;

        # Configure keymap in X11
        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

        # Disable root account
        users.users.root.hashedPassword = null;

        # Create administrator account
        users.users.admin = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          hashedPassword = "$y$j9T$eRYK.qMyLr8TBy/y2I3ax.$K0PIIN7DwrVIqtXaNWyVSMtZUvMRiOjTkmpAxgsHc06";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDr0gT5JTJgVnSmZBW90w2BN/AaBScf5L1UzpdViaesz"
          ];
        };

        # Define a user account. Don't forget to set a password with ‘passwd’.
        users.users.joy = {
          isNormalUser = true;
          extraGroups = [
            "audio"
            "video"
            "networkmanager"
            "gamemode"
          ];
          hashedPassword = ""; # login without password
        };

        # enable autologin
        services.displayManager = {
          enable = true;
          autoLogin = {
            enable = true;
            user = "joy";
          };
        };

        # Install firefox.
        programs.firefox.enable = true;

        programs.neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          defaultEditor = true;
        };

        environment.variables = {
          VISUAL = config.programs.neovim.package;
          SUDO_EDITOR = config.programs.neovim.package;
        };

        systemd.targets.sleep.enable = false;
        systemd.targets.suspend.enable = false;
        systemd.targets.hibernate.enable = false;
        systemd.targets.hybrid-sleep.enable = false;

        # Enable the OpenSSH daemon. services.openssh.enable = true;
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
          };
        };

        services.tailscale.extraUpFlags = [
          "--ssh"
        ];

        boot.initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/a8d62709-1320-49ac-8d90-7932ddf932e6";
          fsType = "ext4";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/688B-F5FE";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };

        swapDevices = [
          { device = "/dev/disk/by-uuid/9698d33b-04d1-493f-8c4b-74a66703b702"; }
        ];

        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        networking.useDHCP = lib.mkDefault true;
        # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
        # networking.interfaces.wlp11s0.useDHCP = lib.mkDefault true;

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };
}
