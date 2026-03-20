-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- General options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = true
vim.opt.clipboard = "unnamedplus"
vim.o.guifont = "FiraCode Nerd Font:14"
vim.opt.cursorline = true
vim.opt.autochdir = true

-- Indentación
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Límite visual
-- vim.opt.colorcolumn = "80"
vim.opt.textwidth = 80

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Plugins
        {
            "ibhagwan/fzf-lua",
            -- optional for icon support
            dependencies = { "nvim-tree/nvim-web-devicons" },
            ---@module "fzf-lua"
            ---@type fzf-lua.Config|{}
            ---@diagnostic disable: missing-fields
            opts = {},
            ---@diagnostic enable: missing-fields
        },
        {
            "maxmx03/solarized.nvim",
            lazy = false,    -- load at startup
            priority = 1000, -- load before other UI plugins
            config = function()
                vim.cmd.colorscheme("solarized")
            end,
        },
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
                require("lualine").setup({
                    options = {
                        theme = "solarized",
                        section_separators = "",
                        component_separators = "",
                    },
                    sections = {
                        lualine_x = {},
                    },
                })
            end,
        },
        {
            "williamboman/mason.nvim",
            config = function()
                require("mason").setup()
            end,
        },

        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = { "mason.nvim" },
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed = { "lua_ls", "ts_ls", "pyright", "clangd", "jdtls" },
                })
            end,
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
            },
            config = function()
                -- New 0.11+ API
                local servers = { "lua_ls", "ts_ls", "pyright", "clangd", "jdtls" }
                for _, server in ipairs(servers) do
                    vim.lsp.config(server, {})
                    vim.lsp.enable(server)
                end

                -- Keymaps
                vim.keymap.set("n", "gd", vim.lsp.buf.definition)
                vim.keymap.set("n", "K", vim.lsp.buf.hover)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
            end,
        },
        {
            "stevearc/conform.nvim",
            event = "BufWritePre", -- carga antes de guardar
            config = function()
                require("conform").setup({
                    formatters_by_ft = {
                        lua = { "stylua" },
                        javascript = { "prettier" },
                        typescript = { "prettier" },
                        python = { "black" },
                    },

                    -- formatear al guardar
                    format_on_save = {
                        timeout_ms = 500,
                        lsp_fallback = true,
                    },
                })
            end,
        },
        {
            'nvim-treesitter/nvim-treesitter',
            lazy = false,
            build = ':TSUpdate',
            config = function()
                require('nvim-treesitter').setup({
                    ensure_installed = { 'javascript', 'typescript', 'python', 'c', 'cpp', 'lua' },
                    highlight = { enable = true },
                })
            end,
        },
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",     -- LSP source
                "hrsh7th/cmp-buffer",       -- Buffer words
                "hrsh7th/cmp-path",         -- File paths
                "L3MON4D3/LuaSnip",         -- Snippet engine (required)
                "saadparwaiz1/cmp_luasnip", -- Snippet source
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ["<C-Space>"] = cmp.mapping.complete(),
                        ["<C-e>"]     = cmp.mapping.abort(),
                        ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                        ["<Tab>"]     = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif luasnip.expand_or_jumpable() then
                                luasnip.expand_or_jump()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<S-Tab>"]   = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                        { name = "buffer" },
                        { name = "path" },
                    }),
                })
            end,
        },
        {
            "iamcco/markdown-preview.nvim",
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            build = "cd app && npm install",
            init = function()
                vim.g.mkdp_filetypes = { "markdown" }
            end,
            ft = { "markdown" },
        },
    },
    -- Colorscheme
    install = { colorscheme = { "solarized" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

-- Keymaps

--General
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Fzf
vim.keymap.set("n", "<leader><leader>", function()
    require("fzf-lua").files()
end)

vim.keymap.set("n", "<leader>/", function()
    require("fzf-lua").live_grep()
end)

vim.keymap.set("n", "<leader>b", function()
    require("fzf-lua").buffers()
end)

vim.keymap.set("n", "<leader>r", function()
    require("fzf-lua").lsp_references()
end)

-- Netrw
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- Neovide
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_scroll_animation_length = 0

-- Treesitter
vim.api.nvim_create_autocmd("FileType", {
    pattern = { 'java', 'javascript', 'typescript', 'python', 'c', 'cpp', 'lua' },
    callback = function()
        vim.treesitter.start()
    end,
})

-- Diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist)
