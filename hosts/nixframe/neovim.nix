{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings = {
      vim = {
        options = {
          expandtab = true; # replace tabs with spaces
          softtabstop = 2; # when combined with expandtab, will write two spaces when tab is used
          shiftwidth = 4; # four spaces used with indenting
          autoindent = true; # copy previous line indent when move to new line
          smarttab = true; # use shiftwidth in front of line and softtabstop otherwise for tab and bksp
        };
        keymaps = [
          {
            key = "<Esc><Esc>";
            mode = "t";
            silent = true;
            action = "<C-\\><C-n>";
          }
        ];
        extraPackages = [
          # yq-go needed for papis.nvim
          pkgs.yq-go
        ];
        binds.whichKey.enable = true;
        viAlias = true;
        vimAlias = true;

        lsp = {
          enable = true;
          mappings.nextDiagnostic = "]d";
          mappings.previousDiagnostic = "[d";
          formatOnSave = true;
          lspconfig.enable = true;
        };
        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            format_on_save = {
              lsp_format = "prefer";
            };
            # stop formatter error from stopping write
            default_format_opts = {
              async = true;
            };
            formatters.prettier.command = "${pkgs.prettier}/bin/prettier";
            formatters_by_ft = {
              html = ["prettier"];
            };
          };
        };

        diagnostics.nvim-lint = {
          enable = true;
          lint_after_save = true;
          linters.tidy.cmd = "${pkgs.html-tidy}/bin/tidy";
          linters_by_ft.html = ["tidy"];
        };
        languages = {
          enableTreesitter = true;
          enableFormat = true;
          html.enable = true;
          css.enable = true;
          nix.enable = true;
          yaml.enable = true;
          lua.enable = true;
          rust.enable = true;
          typst = {
            enable = true;
            format = {
              enable = true;
              type = "typstyle";
            };
          };
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
        utility.preview.markdownPreview.enable = true;
        autocomplete.blink-cmp = {
          enable = true;
          setupOpts.completion.menu.auto_show = false;
        };

        # TODO figure out why pathlib-nvim has to be loaded this way
        # TODO update documentation for use of luaPackages
        luaPackages = ["pathlib-nvim"];
        lazy.plugins = {
          # TODO update docs to explain why plugin name has to have exact format
          # that differs from extraPackages
          "sqlite.lua" = {
            package = pkgs.vimPlugins.sqlite-lua;
            lazy = true;
          };
          "nui.nvim" = {
            package = pkgs.vimPlugins.nui-nvim;
            lazy = true;
          };
          "papis.nvim" = {
            package = pkgs.vimPlugins.papis-nvim;
            setupModule = "papis";
            setupOpts.enable_keymaps = true;
            ft = ["markdown" "typst"];
          };
        };
      };
    };
  };
}
