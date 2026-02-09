return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    -- 1. Initialize Mason
    require("mason").setup()

    -- 2. Define our capabilities (The "Superpowers" for Completion)
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- 3. Setup Mason-LSPConfig AND Handlers in one go
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "gopls" },

      handlers = {
        -- The first entry is the "default handler" for all servers
        function(server_name)
          local server_opts = {
            capabilities = capabilities,
          }

          -- Server-specific overrides
          if server_name == "lua_ls" then
            server_opts.settings = {
              Lua = { diagnostics = { globals = { "vim" } } }
            }
          end

          -- Apply config (0.11+ style)
          if vim.lsp.config then
            vim.lsp.config(server_name, server_opts)
            vim.lsp.enable(server_name)
          else
            require("lspconfig")[server_name].setup(server_opts)
          end
        end,
      }
    })

    -- 4. Native Diagnostic Configuration (0.11 style)
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      update_in_insert = false,
      underline = true,
      severity_sort = true,
      float = { border = "rounded" },
    })

    -- 5. Completion (nvim-cmp)
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
      }),
    })
  end,
}
