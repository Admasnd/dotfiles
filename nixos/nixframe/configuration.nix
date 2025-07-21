# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./base.nix
    ./power.nix
  ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };

  # Needed for blueray drive to work with makemkv
  boot.kernelModules = ["sg"];

  boot.initrd = {
    luks.devices."root" = {
      device = "/dev/disk/by-uuid/16f67ecf-126d-499e-a01e-8e1431c87664"; # UUID for /dev/nvme0n1p2
      preLVM = true;
      keyFile = "/keyfile.bin";
      allowDiscards = true;
    };
    secrets = {
      "keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
    };
  };

  networking.hostName = "nixframe"; # Define your hostname.

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.uinput = {};
  users.groups.plugdev = {};
  users.users.antwane = {
    isNormalUser = true;
    extraGroups = ["wheel" "input" "uinput" "plugdev" "cdrom"];
  };

  environment.systemPackages = with pkgs; [
    # tools for using lazy plugin manager for neovim
    clang
    # emacs
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # auto upgrade settings
  system.autoUpgrade = {
    enable = true;
    flake = "git+file:///home/antwane/dev/dotfiles";
    allowReboot = true;
    dates = "daily";
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
    flags = [
      "--recreate-lock-file"
      "--commit-lock-file"
    ];
  };

  # i18n.inputMethod.enabled = "ibus";
  # i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ mozc ];

  # installs framework laptop firmware manager
  # to update firmware, run: sudo fwupdmgr update
  services.fwupd.enable = true;

  # add ZSA keyboard related udev rules
  services.udev.packages = [
    (pkgs.concatTextFile {
      name = "zsa-udev";
      files = [./50-zsa.rules];
      destination = "/lib/udev/rules.d/50-zsa.rules";
    })
  ];

  services.printing = {
    enable = true;
    drivers = [pkgs.samsung-unified-linux-driver pkgs.brlaser];
  };

  services.borgbackup.jobs.borgbase = {
    paths = "/home/antwane";
    exclude = ["*/Downloads" "*/result" "*/target"];
    doInit = false;
    encryption = {
      mode = "repokey-blake2";
      passCommand = lib.mkDefault "cat path";
    };
    environment.BORG_RSH = "ssh -i /home/antwane/.ssh/id_borgbase";
    repo = lib.mkDefault "repo";
    persistentTimer = true;
    inhibitsSleep = true;
    startAt = "hourly";
    extraCreateArgs = ["--stats" "--verbose"];
  };
  services.borgbackup.jobs.localexternal = {
    paths = "/home/antwane";
    exclude = ["*/Downloads" "*/result" "*/target"];
    doInit = false;
    encryption = {
      mode = "repokey-blake2";
      passCommand = lib.mkDefault "cat path";
    };

    repo = "/run/media/antwane/FRAME-USB/borg";
    inhibitsSleep = true;
    extraCreateArgs = ["--stats" "--verbose"];
    removableDevice = true;
    startAt = "daily";
    persistentTimer = true;
  };

  systemd.services.localexternal.serviceConfig = {
    ConditionPathIsDirectory = "/run/media/antwane/FRAME-USB";
  };
}
