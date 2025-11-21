{
  # Settings shared across hosts
  den.default.nixos = {
    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    nix.gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 14d";
    };

    # Settings shared across hosts
    system.stateVersion = "25.05";

    # Enable networking
    networking.networkmanager.enable = true;
    services.resolved.enable = true;
    networking.networkmanager.dns = "systemd-resolved";

    # Set your time zone.
    time.timeZone = "America/New_York";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    nixpkgs.config.allowUnfree = true;

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;
    boot.initrd.systemd.enable = true;

    # enable flakes support
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Enable networking

    # Set your time zone.

    # Select internationalisation properties.

    # Enable sound with pipewire.
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default, no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
