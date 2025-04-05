{
  pkgs,
  nixpkgs-stable,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  # enables (un)loading environment variables by changing directories
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    # enables nix devshells to be auto loaded from flakes
    nix-direnv.enable = true;
  };
  # let home-manager manage bash
  programs.bash.enable = true;

  home.username = "antwane";
  home.homeDirectory = "/home/antwane";

  home.packages = with nixpkgs-stable.legacyPackages.${pkgs.system};
    [
      # security tools
      bitwarden
      yubikey-manager-qt
      sops
      sparrow
      mullvad-browser
    ]
    ++ (with pkgs; [
      # security tools
      yubioath-flutter
      signal-desktop
      # web tools
      brave
      # mullvad-browser
      google-chrome
      tor-browser-bundle-bin
      thunderbird
      protonmail-bridge
      # writing tools
      libreoffice
      # misc tools
      nerd-fonts.hack
      makemkv
      findutils
      unzip
      handbrake
      (ffmpeg-full.override {
        withUnfree = true;
      })
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

  programs.git = {
    enable = true;
    userName = "Antwane Mason";
    userEmail = "git@aimai.simplelogin.com";
  };

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
  # home.file = {
  #  ".emacs.d/init.el".source = ../../emacs/init.el;
  # };

  # auto configure fonts installed via packages
  fonts.fontconfig.enable = true;

  home.stateVersion = "23.05";
}
