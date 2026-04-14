{
  config,
  ...
}:
let
  topConfig = config;
in
{
  flake.modules.homeManager.laptop =
    {
      lib,
      pkgs,
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

      home.username = "antwane";
      home.homeDirectory = "/home/antwane";

      home.packages = with pkgs; [
        # security tools
        bitwarden-desktop
        sops
        mullvad-browser
        chromium
        signal-desktop
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
        freecad
        racket
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

  flake.modules.nixos.laptop =
    {
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = with topConfig.flake.modules.nixos; [
        (modulesPath + "/installer/scan/not-detected.nix")
        backup
        base
        devenv
        gaming
        udev
        kanata
        nostr
        sops
        power
        tailscale
        yubikey
      ];

      admasnd.dotfiles = {
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
        elan
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
        "sg" # Needed for blueray drive to work with makemkv
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      };
    };
}
