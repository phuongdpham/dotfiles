return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall' },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      -- local lspconfig = require('lspconfig')

      -- 1. Manual Setup for kdl-lsp (since Mason doesn't have it)
      -- We define it directly using nvim-lspconfig's utility
      -- vim.lsp.config('kdl_lsp', {
      --   cmd = { 'kdl-lsp' },
      --   filetypes = { 'kdl' },
      --   root_markers = { '.git', 'niri' },
      --   capabilities = capabilities,
      -- })
      -- vim.lsp.enable('kdl_lsp')

      -- Setup Mason-LSPConfig AND Handlers in one go
      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'gopls' },

        handlers = {
          -- The first entry is the "default handler" for all servers
          function(server_name)
            local server_opts = {
              capabilities = capabilities,
            }

            -- 1. Lua Overrides
            if server_name == 'lua_ls' then
              server_opts.settings = {
                Lua = { diagnostics = { globals = { 'vim' } } },
              }
            end

            -- 2. Go (gopls) Overrides to fix the warnings
            if server_name == 'gopls' then
              server_opts.filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' }

              server_opts.settings = {
                gopls = {
                  usePlaceholders = true,
                  completeUnimported = true,
                },
              }
            end

            -- 3. KDL Overrides (kdl_lsp)
            -- if server_name == 'kdl_lsp' then
            --   server_opts.filetypes = { 'kdl' }
            --   -- Add specific settings here if needed based on crates.io documentation
            -- end

            vim.lsp.config(server_name, server_opts)
            vim.lsp.enable(server_name)
          end,
        },
      }

      -- 4. Native Diagnostic Configuration (0.11 style)
      vim.diagnostic.config {
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = { border = 'rounded' },
      }
    end,
  },
  -- Mason decoupled as a top-level dependency
  { 'mason-org/mason.nvim', cmd = 'Mason', opts = {} },
  { 'mason-org/mason-lspconfig.nvim', lazy = true },
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'default' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
