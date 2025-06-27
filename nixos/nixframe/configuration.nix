# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./base.nix
  ];

  # prevent overheating
  services.thermald.enable = true;

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60min
  '';

  services.logind.lidSwitch = "suspend-then-hibernate";

  services.tlp = {
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "performance";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };
  };

  boot.kernelParams = [
    "mem_sleep_default=deep" # use low-leakage S3
    "intel_idle.max_cstate=9" # let cores reach deepest C-state
    "pcie_aspm.policy=powersupersave"
  ];

  services.logind.extraConfig = ''
    [Sleep]
    SuspendState=deep
  '';

  powerManagement.powertop.enable = true;

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
}
