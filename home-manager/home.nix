{
  pkgs,
  lib,
  nixpkgs-stable,
  nvf,
  private-dotfiles,
  config,
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
      ns = "sudo nixos-rebuild --flake . switch --max-jobs 4 --cores 8";
      nb = "nixos-rebuild --flake . build --max-jobs 4 --cores 8";
      hs = "home-manager --flake . switch --max-jobs 4 --cores 8";
      hb = "home-manager --flake . build --max-jobs 4 --cores 8";
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
    bitwarden
    yubioath-flutter
    sops
    mullvad-browser
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
    moonlight-qt
    typst
    zellij
    roboto
    source-sans-pro
    font-awesome
  ];

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
        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            format_on_save = {
              lsp_format = "prefer";
            };
            formatters.prettier.command = "${pkgs.prettier}/bin/prettier";
            formatters_by_ft = {
              html = ["prettier"];
            };
          };
        };
        languages = {
          enableTreesitter = true;
          enableFormat = true;
          html.enable = true;
          css.enable = true;
          nix.enable = true;
          lua.enable = true;
          rust.enable = true;
          typst.enable = true;
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

  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    TYPST_PACKAGE_PATHS = lib.makeSearchPath "share/typst/packages" [
      pkgs.typstPackages.brilliant-cv
    ];
  };

  # services.ssh-agent.enable = true;

  # auto configure fonts installed via packages
  fonts.fontconfig.enable = true;

  home.stateVersion = "23.05";
}
