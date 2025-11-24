{ den, ... }:
{
  den.aspects.antwane = {
    includes = with den.aspects; [
      git
      neovim
      papis
    ];

    homeManager =
      {
        pkgs,
        lib,
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
          signal-desktop-bin
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
          jujutsu # better git
          tmux
          nodejs
          radicle-node
          moonlight-qt
          typst
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

        # auto configure fonts installed via packages
        fonts.fontconfig.enable = true;

        home.stateVersion = "23.05";
      };
  };
}
