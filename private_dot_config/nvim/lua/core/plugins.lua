local pack = vim.pack

-- 1. Foundation / Dependencies (Order matters natively!)
pack.add {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/folke/persistence.nvim',
}

-- 2. Core UI & Navigation
pack.add {
    'https://github.com/folke/tokyonight.nvim',
    'https://github.com/folke/snacks.nvim',
    'https://github.com/folke/which-key.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    {
        src = 'https://github.com/ThePrimeagen/harpoon',
        name = 'harpoon2',
        version = 'harpoon2',
    },
    'https://github.com/christoomey/vim-tmux-navigator',
    'https://github.com/akinsho/bufferline.nvim',
    'https://github.com/nvim-lualine/lualine.nvim',
    'https://github.com/folke/trouble.nvim',
    'https://github.com/echasnovski/mini.icons',
    'https://github.com/lewis6991/gitsigns.nvim',
    'https://github.com/tpope/vim-fugitive',
    'https://github.com/saecki/crates.nvim',
}

-- 3. System Integration
pack.add {
    'https://github.com/xvzc/chezmoi.nvim',
}

-- 4. Formatting & Syntax
pack.add {
    'https://github.com/stevearc/conform.nvim',
    {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter',
        version = 'main',
    },
    'https://github.com/windwp/nvim-autopairs',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}

-- 5. Completion
pack.add {
    'https://github.com/Saghen/blink.cmp',
}

-- ==========================================
-- Explicit Plugin Setup (No magic config blocks)
-- ==========================================
vim.cmd.colorscheme('tokyonight')

-- Render Markdown
vim.opt.conceallevel = 2 -- Required to hide raw markdown formatting

require('persistence').setup {
    -- Directory where session files are saved
    dir = vim.fn.stdpath('state') .. '/sessions/',
    options = { 'buffers', 'curdir', 'tabpages', 'winsize' },
}

local icons = require('mini.icons')
icons.setup {
    -- You can customize specific icons here if you want
    file = {
        -- Example: Custom icon for Go files if you prefer something specific
        -- [".go"] = { glyph = "󰟓", hl = "MiniIconsBlue" },
    },
}

-- This line tells other plugins like Lualine/Trouble to use mini.icons
icons.mock_nvim_web_devicons()

require('trouble').setup {
    auto_close = true,     -- Close the list when you open a file
    restore_window = true, -- Restore last window configuration
    padding = false,       -- Move text to the left for more space
    icons = true,          -- Use devicons
    modes = {
        -- Configuration for diagnostics list
        diagnostics = {
            auto_open = false,
            filter = {
                -- Only show errors/warnings, skip hints/info if they are too noisy
                severity = vim.diagnostic.severity.ERROR,
            },
        },
    },
}

require('render-markdown').setup {
    heading = {
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        foregrounds = {
            'DiagnosticInfo',  -- Blue-ish
            'DiagnosticWarn',  -- Orange/Peach-ish
            'DiagnosticOk',    -- Green
            'DiagnosticHint',  -- Purple/Mauve-ish
            'DiagnosticError', -- Red
            'Special',         -- Yellow-ish
        },
    },
    code = {
        sign = false,
        width = 'block',
        right_pad = 1,
        highlight = 'RenderMarkdownCode',
    },
    checkbox = {
        enabled = true,
        unchecked = { icon = '󰄱 ' },
        checked = { icon = '󰄵 ' },
    },
}

require('lualine').setup {
    options = {
        theme = 'tokyonight',
        globalstatus = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'snacks_dashboard', 'snacks_explorer' } },
    },
    sections = {
        lualine_a = { { 'mode' } },
        lualine_b = { { 'branch', icon = '' }, 'diff', 'diagnostics' },
        lualine_c = {
            { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' ', unnamed = '[No Name]' } },
        },
        lualine_x = {
            -- Custom component to show active LSP names
            {
                function()
                    local msg = 'No LSP'
                    local clients = vim.lsp.get_clients { bufnr = 0 }
                    if next(clients) == nil then
                        return msg
                    end
                    local client_names = {}
                    for _, client in ipairs(clients) do
                        table.insert(client_names, client.name)
                    end
                    return ' ' .. table.concat(client_names, ' | ')
                end,
                color = { fg = '#7aa2f7', gui = 'bold' },
            },
            'encoding',
            'fileformat',
            'filetype',
        },
        lualine_y = {
            { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } }, },
        lualine_z = {
            {
                'datetime',
                -- options: default, us, uk, iso, or your own format string ("%H:%M", etc..)
                style = 'default'
            }
        },
    },
}

-- Apply your custom code block background link
vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { link = 'NormalFloat', default = true })

-- Snacks Configuration
require('snacks').setup {
    bigfile = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = false },
    statusline = { enabled = false },
}

-- Conform Formatters
require('conform').setup {
    formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'goimports', 'gofmt' },
        java = { 'google-java-format' },
        sh = { 'shfmt' },
        rust = { 'rustfmt' },
        -- kdl = { 'kdlfmt' },
        ['_'] = { 'trim_whitespace' },
    },
}

-- Autopairs
require('nvim-autopairs').setup { check_ts = true }

-- Blink.cmp
require('blink.cmp').setup {
    keymap = { preset = 'default' },
    appearance = {
        nerd_font_variant = 'mono',
        highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
    },
    completion = { documentation = { auto_show = false } },
    sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
}

-- Chezmoi
require('chezmoi').setup {
    edit = {
        watch = false,
        force = false,
        ignore_patterns = {
            "run_onchange_.*",
            "run_once_.*",
            "%.chezmoiignore",
            "%.chezmoitemplate",
            -- Add custom patterns here
        },
    },
    events = {
        on_open = {
            notification = {
                enable = true,
                msg = "Opened a chezmoi-managed file",
                opts = {},
            },
        },
        on_watch = {
            notification = {
                enable = true,
                msg = "This file will be automatically applied",
                opts = {},
            },
        },
        on_apply = {
            notification = {
                enable = true,
                msg = "Successfully applied",
                opts = {},
            },
        },
    },
    telescope = { select = { '<CR>' } },
}

-- Which-Key
local wk = require("which-key")
wk.setup {
    preset = 'helix', -- The 'helix' preset looks fantastic with Tokyonight
    delay = 0,
}

-- (Optional) Name your shortcut groups so the menu looks organized
wk.add({
    { '<leader>c', group = 'Code / Chezmoi' },
    { '<leader>f', group = 'Find / File' },
    { '<leader>h', group = 'Gitsigns', icon = "󰊢 " },
    { '<leader>p', group = 'Persistence session' },
    { '<leader>g', group = 'Git / GitHub' },
    { '<leader>r', group = 'Reload' },
    { '<leader>s', group = 'Grep / Search' },
    { '<leader>t', group = 'Toggles' },
    {
        "<leader>b",
        group = "buffers",
        expand = function()
            return require("which-key.extras").expand.buf()
        end
    },
    {
        -- Nested mappings are allowed and can be added in any order
        -- Most attributes can be inherited or overridden on any level
        -- There's no limit to the depth of nesting
        mode = { "n", "v" }, -- NORMAL and VISUAL mode
        { "<leader>w", "<cmd>w<cr>", desc = "Write" },
    }
})

-- ==========================================
-- Tree-sitter (New v1.0 / Main Branch API)
-- ==========================================
local ts = require('nvim-treesitter')

ts.setup {
    -- Keep parsers in the standard data path
    install_dir = vim.fn.stdpath('data') .. '/site',
}

-- Register custom languages
vim.treesitter.language.register('gotmpl', 'gotmpl')

-- 1. Install parsers directly via the new API
ts.install {
    'bash',
    'c',
    'cmake',
    'cpp',
    'go',
    'java',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'rust',
    'sql',
    'vim',
    'yaml',
    'kdl',
    'regex',
    'html',
    'latex',
    'css',
    'javascript',
    'scss',
    'svelte',
    'tsx',
    'typst',
    'vue',
}

-- 2. Activate Highlighting, Folds, and Indents natively
-- The new API drops the 'highlight = { enable = true }' table
-- in favor of standard Neovim core functions.
vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        local bufnr = args.buf
        local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) or vim.bo[bufnr].filetype

        -- Start the native treesitter highlighting engine
        if pcall(vim.treesitter.start, bufnr, lang) then
            -- Enable Treesitter Folds
            vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local' })
            vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.treesitter.foldexpr()', { scope = 'local' })
            vim.api.nvim_set_option_value('foldlevel', 99, { scope = 'local' })

            -- Enable Treesitter Indents
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

-- Bufferline (Visual Tabs)
require('bufferline').setup {
    options = {
        -- Integration with Snacks for closing buffers
        close_command = function(n)
            require('snacks').bufdelete(n)
        end,
        right_mouse_command = function(n)
            require('snacks').bufdelete(n)
        end,

        diagnostics = 'nvim_lsp',
        always_show_bufferline = false,

        -- Native diagnostics indicator (Replaces LazyVim icons)
        diagnostics_indicator = function(_, _, diag)
            local s = ''
            if diag.error then
                s = s .. ' ' .. diag.error .. ' '
            end
            if diag.warning then
                s = s .. ' ' .. diag.warning
            end
            return vim.trim(s)
        end,

        offsets = {
            {
                filetype = 'snacks_explorer',
                text = 'File Explorer',
                highlight = 'Directory',
                text_align = 'left',
            },
            {
                filetype = 'snacks_layout_box',
            },
        },
        -- Use web-devicons natively
        color_icons = true,
        show_buffer_icons = true,
    },
}

require('gitsigns').setup {
    signs                        = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    signs_staged                 = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    signs_staged_enable          = true,
    signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir                 = {
        follow_files = true
    },
    auto_attach                  = true,
    attach_to_untracked          = false,
    current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    blame_formatter              = nil, -- Use default
    sign_priority                = 6,
    update_debounce              = 100,
    status_formatter             = nil,   -- Use default
    max_file_length              = 40000, -- Disable if file is longer than this (in lines)
    preview_config               = {
        -- Options passed to nvim_open_win
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
    on_attach                    = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then
                vim.cmd.normal({ ']c', bang = true })
            else
                gitsigns.nav_hunk('next')
            end
        end, { desc = 'Next Hunk' })

        map('n', '[c', function()
            if vim.wo.diff then
                vim.cmd.normal({ '[c', bang = true })
            else
                gitsigns.nav_hunk('prev')
            end
        end, { desc = 'Prev Hunk' })

        -- Actions
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Stage Hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Reset Hunk' })

        map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Stage Hunk Selected' })

        map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Reset Hunk Selected' })

        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Stage Buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Reset Buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview Hunk' })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'Preview Hunk Inline' })

        map('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
        end, { desc = 'Blame line' })

        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff' })

        map('n', '<leader>hD', function()
            gitsigns.diffthis('~')
        end, { desc = 'Diff ~' })

        map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, { desc = 'Setqflist All' })
        map('n', '<leader>hq', gitsigns.setqflist, { desc = 'Setqflist' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle Current Line Blame' })
        map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = 'Toggle Word Diff' })

        -- Text object
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'Select Hunk' })
    end
}

-- Creates
require('crates').setup {
    lsp = {
        enabled = true,
        on_attach = function(client, bufnr)
            -- Optional: add your specific keymaps here
        end,
        actions = true,
        completion = true,
        hover = true,
    },
}
