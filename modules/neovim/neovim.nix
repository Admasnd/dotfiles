{ inputs, ... }:
{
  den.aspects.neovim = {
    homeManager =
      {
        pkgs,
        ...
      }:
      let
        golf-vim = pkgs.vimUtils.buildVimPlugin {
          name = "golf.vim";
          src = inputs.golf-vim;
        };
        one-small-step-for-vimkind = pkgs.vimUtils.buildVimPlugin {
          name = "one-small-step-for-vimkind";
          src = inputs.one-small-step-for-vimkind;
        };
        vimdirdiff = pkgs.writeShellApplication {
          name = "vimdirdiff";
          text = ''
            #!/bin/bash
            # On Mac OS, you may need to replace `/bin/bash` with `/bin/zsh`.

            # Shell-escape each path:
            DIR1=$(printf '%q' "$1"); shift
            DIR2=$(printf '%q' "$1"); shift
            # Setting the colorscheme is optional
            vim "$@" -c "DirDiff $DIR1 $DIR2"
          '';
        };
      in
      {
        home.packages = [ vimdirdiff ];
        programs.neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          extraPackages = with pkgs; [
            cargo
            emmet-language-server # for html and css
            fd
            htmlhint # HTML linter
            lua-language-server
            marksman # Markdown LSP
            nixd # Nix LSP
            nixfmt # Nix formatter
            prettierd # General formatter
            ripgrep # for telescope
            rust-analyzer # for Rust LSP support
            rustc
            rustfmt
            tinymist # Typst lsp
            typstyle # Typst formatter
            yaml-language-server
            yq-go # for papis.nvim
          ];
          plugins = with pkgs.vimPlugins; [
            conform-nvim
            vim-dirdiff
            golf-vim
            hardtime-nvim
            lazydev-nvim
            mini-ai
            mini-surround
            nord-vim
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
            nvim-lint
            nvim-lspconfig
            nvim-treesitter
            nvim-treesitter-parsers.css
            nvim-treesitter-parsers.html
            nvim-treesitter-parsers.lua
            nvim-treesitter-parsers.markdown
            nvim-treesitter-parsers.markdown_inline
            nvim-treesitter-parsers.nix
            nvim-treesitter-parsers.rust
            nvim-treesitter-parsers.typst
            nvim-treesitter-parsers.yaml
            nvim-treesitter-textobjects
            papis-nvim
            oil-nvim
            one-small-step-for-vimkind
            render-markdown-nvim
            telescope-nvim
            telescope-fzf-native-nvim
            typst-preview-nvim
            which-key-nvim
          ];
        };

        xdg.configFile."nvim".source = ./nvim;
      };
  };
}
