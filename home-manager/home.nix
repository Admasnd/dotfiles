{
  pkgs,
  nixpkgs-stable,
  nvf,
  private-dotfiles,
  ...
}: {
  imports = [
    nvf.homeManagerModules.default
    private-dotfiles.homeManagerModules.packages
    ./git.nix
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
      ns = "sudo nixos-rebuild --flake . switch";
      nb = "sudo nixos-rebuild --flake . build";
      hs = "home-manager --flake . switch";
      hb = "home-manager --flake . build";
      ll = "ls -la";
      fu = "nix flake update";
    };
  };

  home.username = "antwane";
  home.homeDirectory = "/home/antwane";

  home.packages = with nixpkgs-stable.legacyPackages.${pkgs.system};
    [
      # security tools
      bitwarden
      yubikey-manager-qt
      sops
      mullvad-browser
    ]
    ++ (with pkgs; [
      # security tools
      yubioath-flutter
      signal-desktop-bin
      # web tools
      brave
      google-chrome
      tor-browser-bundle-bin
      thunderbird
      protonmail-bridge
      # writing tools
      libreoffice
      # misc tools
      nerd-fonts.hack
      findutils
      unzip
      evtest # for keyboard input testing
      papis
      evince
      fzf
      age
      vorta
      vlc
      # programming
      tmux
      nodejs
      rustup
      radicle-node
    ]);

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        binds.whichKey.enable = true;
        viAlias = true;
        vimAlias = true;
        lsp = {
          enable = true;
          mappings.nextDiagnostic = "]d";
          mappings.previousDiagnostic = "[d";
          formatOnSave = true;
        };
        languages = {
          enableLSP = true;
          enableTreesitter = true;
          enableFormat = true;
          nix.enable = true;
          lua.enable = true;
          rust.enable = true;
          markdown = {
            enable = true;
            extensions.render-markdown-nvim.enable = true;
          };
        };
        statusline.lualine.enable = true;
        telescope.enable = true;
        telescope.setupOpts.defaults.layout_strategy = "center";
        theme = {
          enable = true;
          name = "tokyonight";
          style = "moon";
        };
      };
    };
  };

  # auto configure fonts installed via packages
  fonts.fontconfig.enable = true;

  home.stateVersion = "23.05";
}
