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
---@brief
---
--- https://github.com/golang/tools/tree/master/gopls
---
--- Google's lsp server for golang.

--- @class go_dir_custom_args
---
--- @field envvar_id string
---
--- @field custom_subdir string?

local mod_cache = nil
local std_lib = nil

---@param custom_args go_dir_custom_args
---@param on_complete fun(dir: string | nil)
local function identify_go_dir(custom_args, on_complete)
    local cmd = { 'go', 'env', custom_args.envvar_id }
    vim.system(cmd, { text = true }, function(output)
        local res = vim.trim(output.stdout or '')
        if output.code == 0 and res ~= '' then
            if custom_args.custom_subdir and custom_args.custom_subdir ~= '' then
                res = res .. custom_args.custom_subdir
            end
            on_complete(res)
        else
            vim.schedule(function()
                vim.notify(
                    ('[gopls] identify ' .. custom_args.envvar_id .. ' dir cmd failed with code %d: %s\n%s'):format(
                        output.code,
                        vim.inspect(cmd),
                        output.stderr
                    )
                )
            end)
            on_complete(nil)
        end
    end)
end

---@return string?
local function get_std_lib_dir()
    if std_lib and std_lib ~= '' then
        return std_lib
    end

    identify_go_dir({ envvar_id = 'GOROOT', custom_subdir = '/src' }, function(dir)
        if dir then
            std_lib = dir
        end
    end)
    return std_lib
end

---@return string?
local function get_mod_cache_dir()
    if mod_cache and mod_cache ~= '' then
        return mod_cache
    end

    identify_go_dir({ envvar_id = 'GOMODCACHE' }, function(dir)
        if dir then
            mod_cache = dir
        end
    end)
    return mod_cache
end

---@param fname string
---@return string?
local function get_root_dir(fname)
    if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
        local clients = vim.lsp.get_clients({ name = 'gopls' })
        if #clients > 0 then
            return clients[#clients].config.root_dir
        end
    end
    if std_lib and fname:sub(1, #std_lib) == std_lib then
        local clients = vim.lsp.get_clients({ name = 'gopls' })
        if #clients > 0 then
            return clients[#clients].config.root_dir
        end
    end
    return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '.git')
end

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
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        get_mod_cache_dir()
        get_std_lib_dir()
        -- see: https://github.com/neovim/nvim-lspconfig/issues/804
        on_dir(get_root_dir(fname))
    end,
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

-- Taplo
lsp.config('taplo', {
    cmd = { 'taplo', 'lsp', 'stdio' },
    filetypes = { 'toml' },
    root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
    settings = {
        evenBetterToml = {
            schema = {
                enabled = true,
            },
            completion = {
                -- Disable Taplo's version suggestions to let crates.nvim take over
                external_references = false,
            },
        },
    },
})
lsp.enable('taplo')

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
