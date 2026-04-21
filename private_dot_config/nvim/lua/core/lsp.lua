local lsp = vim.lsp
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Lua
lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Register both vim and Snacks as global variables
                globals = { 'vim', 'Snacks' },
            },
            workspace = {
                -- This is the "magic" that makes the LSP aware of all Neovim functions
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                    -- This adds Snacks and other plugins to the LSP's path
                    vim.fn.stdpath("data") .. "/site/pack/core/opt/snacks.nvim",
                },
                checkThirdParty = false,
            },
            telemetry = { enabled = false },
        },
    },
})
lsp.enable('lua_ls')

-- High-performance Go Backend
lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    capabilities = capabilities,
    settings = {
        gopls = {
            semanticTokens = true,
            analyses = { unusedparams = true },
            staticcheck = true,
        },
    },
})
lsp.enable('gopls')

-- Java / Spring Boot Setup
lsp.config('jdtls', {
    cmd = { 'jdtls' },
    filetypes = { 'java' },
    capabilities = capabilities,
})
lsp.enable('jdtls')

-- Rust Setup (Native 0.12 style)
lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    capabilities = capabilities,
    root_markers = { 'Cargo.toml', 'rust-project.json' },
    settings = {
        ['rust-analyzer'] = {
            -- 1. This is now a simple toggle (boolean)
            checkOnSave = true,

            -- 2. The configuration map moved here
            check = {
                command = "clippy",
                extraArgs = { "--no-deps" }, -- Optional: makes clippy faster
            },
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },

            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true,
            },
        },
    },
})
lsp.enable('rust_analyzer')

local orig_hover = vim.lsp.buf.hover
vim.lsp.buf.hover = function(opts)
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    return orig_hover(opts)
end

-- Create a global wrapper for Signature Help
local orig_sig = vim.lsp.buf.signature_help
vim.lsp.buf.signature_help = function(opts)
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    return orig_sig(opts)
end

-- Python Setup (Senior-level performance)
lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly', -- Saves CPU on large repos
                typeCheckingMode = 'basic',       -- 'strict' if you want Go-like type safety
            },
        },
    },
})
lsp.enable('pyright')

-- Ruff
lsp.config('ruff', {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    capabilities = capabilities,
})
lsp.enable('ruff')

vim.diagnostic.config({
    -- We keep virtual_text but make it minimal since we have the Trouble list
    virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN }, -- Hide HINT/INFO in virtual text
        prefix = '●',
        spacing = 4,
    },
    -- Ensure signs (icons in the gutter) are visible
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded' },
})
