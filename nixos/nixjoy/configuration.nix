# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: let
  port = config.services.sunshine.settings.port;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  services.sunshine.enable = true;
  # systemd.user.services.sunshine
  systemd.user.services.sunshine.after = ["tailscaled.service"];
  systemd.user.services.sunshine.requires = ["tailscaled.service"];
  systemd.user.services.sunshine.preStart = ''
    ${pkgs.tailscale}/bin/tailscale serve --bg --tcp ${toString port} ${toString port}
  '';

  systemd.user.services.sunshine.postStop = ''
    ${pkgs.tailscale}/bin/tailscale serve --tcp ${toString port} off
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixjoy"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary networking.proxy.default = "http://user:password@proxy:port/"; networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default, no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager). services.xserver.libinput.enable = true;

  # Disable root account
  users.users.root.hashedPassword = null;

  # Create administrator account
  users.users.admin = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    hashedPassword = "$y$j9T$eRYK.qMyLr8TBy/y2I3ax.$K0PIIN7DwrVIqtXaNWyVSMtZUvMRiOjTkmpAxgsHc06";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDr0gT5JTJgVnSmZBW90w2BN/AaBScf5L1UzpdViaesz"];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.joy = {
    isNormalUser = true;
    extraGroups = ["audio" "video" "networkmanager" "gamemode"];
    hashedPassword = ""; # login without password
    # packages = with pkgs; [
    # ];
  };

  # enable autologin
  services.displayManager = {
    enable = true;
    autoLogin = {
      enable = true;
      user = "joy";
    };
  };

  # Wayland compositor that runs a single, maximized app
  # services.cage = {
  #   enable = true;
  #   user = "joy";
  #   program = "${pkgs.steam}/bin/steam -bigpicture";
  # };

  # Install firefox.
  programs.firefox.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {extraPkgs = pkgs: with pkgs; [mangohud];};
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.variables = {
    VISUAL = config.programs.neovim.package;
    SUDO_EDITOR = config.programs.neovim.package;
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default. wget
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true; programs.gnupg.agent = {
  #   enable = true; enableSSHSupport = true;
  # };

  # List services that you want to enable:

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

  # Open ports in the firewall. networking.firewall.allowedTCPPorts = [ ... ]; networking.firewall.allowedUDPPorts = [ ... ]; Or disable the firewall altogether. networking.firewall.enable = false;

  # This value determines the NixOS release from which the default settings for stateful data, like file locations and database versions on your system were taken. It‘s perfectly fine and recommended to leave this value at the release version of the first install of this system. Before changing this value read the documentation for this option (e.g. man configuration.nix or on
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
