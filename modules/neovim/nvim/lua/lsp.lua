-- Section LSP Attach autocmd
vim.api.nvim_create_autocmd('LspAttach', {
    desc = "Enables completion support if available",
    group = vim.api.nvim_create_augroup("myconfig-lsp-attach", { clear = true }),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        -- try to enable completion support for buffer
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, args.buf, {})
        end
    end,
})

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

-- Section Emmet Language Support
vim.lsp.config('emmet_language_server', {
    init_options = {
        showAbbreviationSuggestions = true,
        showExpandedAbbreviaton = "always",
        triggerExpansionOnTab = true,
    },
})
vim.lsp.enable('emmet_language_server')

-- Section Javascript/Typescript Support
vim.lsp.enable('ts_ls')
