{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.laptop = moduleWithSystem (
    { config, ... }:
    { ... }:
    {
      programs.neovim = {
        enable = true;
        package = config.packages.myNeovim;
        viAlias = true;
        vimAlias = true;
        withRuby = false;
        withPython3 = false;
      };
    }
  );

  perSystem =
    { pkgs, ... }:
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
      packages.myNeovim = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        runtimePkgs = with pkgs; [
          cargo
          emmet-language-server # for html and css
          fd
          htmlhint # HTML linter
          lua-language-server
          marksman # Markdown LSP
          nixd # Nix LSP
          nixfmt # Nix formatter
          tree-sitter
          prettierd # General formatter
          ripgrep # for telescope
          rust-analyzer # for Rust LSP support
          rustc
          rustfmt
          tinymist # Typst lsp
          typescript-language-server
          typstyle # Typst formatter
          yaml-language-server
          yq-go # for papis.nvim
          vimdirdiff
        ];

        specs.general = with pkgs.vimPlugins; [
          conform-nvim
          vim-dirdiff
          golf-vim
          hardtime-nvim
          lazydev-nvim
          lean-nvim
          mini-ai
          mini-surround
          nord-vim
          nui-nvim
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
          plenary-nvim
          oil-nvim
          one-small-step-for-vimkind
          render-markdown-nvim
          sqlite-lua
          telescope-nvim
          telescope-fzf-native-nvim
          typst-preview-nvim
          which-key-nvim
        ];

        settings.config_directory = ./nvim;
      };
    };
}
