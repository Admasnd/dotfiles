{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # inputs.private-dotfiles.homeManagerModules.packages
    ./git.nix
    (import ./neovim.nix {
      inherit inputs;
      inherit pkgs;
    })
  ];

  programs.home-manager.enable = true;

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
    '';
  };

  home.username = "antwane";
  home.homeDirectory = "/home/antwane";

  home.packages = with pkgs; [
    # security tools
    bitwarden-desktop
    yubioath-flutter
    yubikey-manager
    sops
    mullvad-browser
    signal-desktop-bin
    # web tools
    brave
    google-chrome
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
    inputs.nixpkgs-stable.legacyPackages.x86_64-linux.papis
    evince
    fzf
    age
    vorta
    vlc
    jq
    zoxide # cd alternative
    yazi # file manager tui
    fd # find replacement
    # programming
    tmux
    nodejs
    radicle-node
    moonlight-qt
    typst
    kanata
    radicle-node
  ];

  home.sessionVariables = {
    # SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    TYPST_PACKAGE_PATH = lib.makeSearchPath "share/typst/packages" [
      pkgs.typstPackages.brilliant-cv
      pkgs.typstPackages.touying
      pkgs.typstPackages.numbly
    ];
  };

  xdg.configFile."papis/config".source = ./papis/config;

  # services.ssh-agent.enable = true;

  # auto configure fonts installed via packages
  fonts.fontconfig.enable = true;

  home.stateVersion = "23.05";
}
