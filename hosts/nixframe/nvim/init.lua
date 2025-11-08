-- This added so that it can be overrided while debugging config
-- Usage: nvim --cmd "lua vim.g.init_debug=true"
-- This will freeze the nvim instance so that the other instance instance can connect
if vim.g.init_debug then
    require "osv".launch({ port = 8086, blocking = true })
end

-- Config adapted from kickstart.nvim
-- Section: Commands & Options
vim.cmd('colorscheme nord')
vim.g.mapleader = ' '
vim.g.maplocalleader = ' ' -- buffer local leader
vim.go.cmdheight = 2       -- use two screen lines to have space for modeline and hardtime.nvim message
vim.o.autoindent = true    -- copy previous line indent when move to new line
vim.o.breakindent = true   -- line wrapped text appear visually indented same level as line
vim.o.confirm = true       -- raise a dialog to save rather than fail command due to unsaved changes
vim.o.cursorline = true    -- visually highlight line cursor is on
vim.o.expandtab = true     -- replace tabs with spaces
vim.o.helpheight = 0       -- turn off minimum help height so it defaults to half the current window
vim.o.ignorecase = true
vim.o.inccommand = 'split' -- Preview substitutions live, as you type!
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10    -- Minimal number of screen lines to keep above and below the cursor.
vim.o.shiftwidth = 4    -- four spaces used with indenting
vim.o.smartcase = true  -- ignore 'ignorecase' if capital letters used in search pattern
vim.o.smarttab = true   -- use shiftwidth in front of line and softtabstop otherwise for tab and bksp
vim.o.softtabstop = 2   -- when combined with expandtab, will write two spaces when tab is used
vim.o.splitbelow = true -- :split will default to below current window
vim.o.splitright = true -- :vsplit will default to the right of current window
vim.o.timeoutlen = 300  -- Decrease mapped sequence wait time
vim.o.updatetime = 250  -- Decrease time without typing before swap file written to disk

-- Section: Autocommands (Excluding LSP & Plugins)
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})
vim.api.nvim_create_autocmd('FileType', {
    desc = 'Start treesitter and configure folding',
    group = vim.api.nvim_create_augroup('myconfig-treesitter-start', { clear = true }),
    callback = function(args)
        if require("nvim-treesitter.parsers").has_parser() then
            vim.treesitter.start(args.buf)
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo.foldmethod = 'expr'
            vim.wo.foldlevel = 99 -- default is to keep folds open
        end
    end
})
vim.api.nvim_create_autocmd('BufNew', {
    desc = 'Enable spell checking when opening new buffer',
    group = vim.api.nvim_create_augroup('myconfig-start-spell', { clear = true }),
    callback = function(args)
        vim.o.spelllang = 'en_us'
        vim.o.spell = true
    end
})

-- Section: LSP Configuration
require("lsp")

-- Section: Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = "Turn off search highlighting" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>?",
    function()
        require("which-key").show()
    end,
    { desc = "Keymaps (which-key)" })

-- Section: Telescope Configuration
require('telescope').setup {
    defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
            i = {
                -- map actions.which_key to <C-h> (default: <C-/>)
                -- actions.which_key shows the mappings for your picker,
                -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                ["<C-h>"] = "which_key"
            }
        }
    }
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fm', builtin.man_pages, { desc = 'Telescope man pages' })
vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Telescope quickfix' })
vim.keymap.set('n', '<leader>fd',
    function() builtin.diagnostics({ bufnr = 0 }) end,
    { desc = 'Telescope LSP diagnostics (current buffer)' })
vim.keymap.set('n', '<leader>fD', builtin.diagnostics, { desc = 'Telescope LSP diagnostics (global)' })
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

-- Section: Language Formatting Support
--  install conform compatibility layer use formatters like LSP formatter
require("conform").setup {
    -- Set this to change the default values when calling conform.format()
    -- This will also affect the default values for format_on_save/format_after_save
    default_format_opts = {
        lsp_format = "fallback",
    },
    -- If this is set, Conform will run the formatter on save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_format = "fallback",
        timeout_ms = 500,
    },
    formatters_by_ft = {
        nix = { "nixfmt" },
        markdown = { "prettierd" },
        typst = { "typstyle" },
    }
}

-- Section: Markdown Support
require('render-markdown').setup {
    html = { enabled = false },
    latex = { enabled = false },
}

-- Section: Oil Setup
require("oil").setup {}

-- Section: Papis.nvim Setup
---@diagnostic disable: missing-fields
require("papis").setup {
    enable_keymaps = true,
    ["ask"] = {
        enable = false,
    },
    ["completion"] = {
        enable = false,
    },
}

-- Section: DAP Setup
local dap = require("dap")
dap.configurations.lua = {
    {
        type = 'nlua',
        request = 'attach',
        name = "Attach to running Neovim instance",
    }
}
dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
end
vim.keymap.set('n', '<leader>db', require("dap").toggle_breakpoint, {
    noremap = true,
    desc = "Toggle breakpoint"
})
vim.keymap.set('n', '<leader>dc', require("dap").continue, {
    noremap = true,
    desc = "Start/resume debugger"
})
vim.keymap.set('n', '<leader>do', require("dap").step_over, {
    noremap = true,
    desc = "Step over code in debugger"
})
vim.keymap.set('n', '<leader>di', require("dap").step_into, {
    noremap = true,
    desc = "Step into code in debugger"
})
local dapui = require("dapui")
dapui.setup()
require("nvim-dap-virtual-text").setup {}
vim.keymap.set('n', '<leader>dt', dapui.toggle, { desc = "Toggle DAP UI" })
vim.keymap.set('n', '<leader>dn', function()
    require("osv").launch({ port = 8086 })
end, {
    noremap = true,
    desc = "Launch lua DAP server on debugee neovim instance"
})

-- Section: typst-preview Setup
require("typst-preview").setup {}

-- Section: nvim-lint Setup
require("lint").linters_by_ft = {
    html = { 'htmlhint' },
}
-- done as post rather than pre because some linters require file to be written to disk first
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    desc = 'Automatically run linter on save',
    group = vim.api.nvim_create_augroup('myconfig-auto-lint-on-save', { clear = true }),
    callback = function()
        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        -- for the current filetype
        require("lint").try_lint()
    end,
})

-- Section: hardtime.nvim Setup
require("hardtime").setup {}
