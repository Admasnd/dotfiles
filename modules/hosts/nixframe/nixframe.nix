{ den, inputs, ... }:
{
  den.aspects.nixframe =
    { aspect, ... }:
    {
      includes = with den.aspects; [
        backup
        # Enables importing home-manager module and wiring up user aspect
        den._.home-manager
        git
        keyboards._.laptop
        keyboards._.voyager
        neovim
        papis
        power
        tailscale
        yubikey
      ];

      nixos =
        {
          config,
          lib,
          modulesPath,
          pkgs,
          ...
        }:

        {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            inputs.private-dotfiles.nixosModules.tailscale
            inputs.private-dotfiles.nixosModules.backup
            inputs.private-dotfiles.nixosModules.pam
            inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
            inputs.disko.nixosModules.disko
          ];

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
            git
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

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
          xdg.portal = {
            enable = true;
            extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
          };
        };
    };
}
