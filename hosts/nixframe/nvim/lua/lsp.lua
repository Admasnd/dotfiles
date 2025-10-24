-- Section Nix Language Support
-- TODO update documentation as needed for nixd, nixfmt, and lspconfig
vim.lsp.enable('nixd')

-- Section Lua Language Support
require("lazydev").setup {
    library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
}
vim.lsp.enable('lua_ls')

-- Section Markdown Language Support
vim.lsp.enable('marksman')

-- Section YAML Language Support
vim.lsp.enable('yamlls')

-- Section Rust Language Support
vim.lsp.enable('rust_analyzer')

-- Section Typst Language Support
vim.lsp.enable('tinymist')

-- Section HTML Language Support
vim.lsp.enable('html')

-- Section CSS Language Support
vim.lsp.enable('cssls')
