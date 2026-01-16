{ inputs, ... }:
{
  flake.modules.nixos.base = {
    imports = [
      inputs.disko.nixosModules.disko
    ];

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

    # Enable sound with pipewire.
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # necessary for bash to completion
    environment.pathsToLink = [ "/share/bash-completion" ];
  };
}
