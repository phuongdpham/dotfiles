return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    -- 1. Ensure you are on the new main branch
    branch = 'main',
    version = false,
    build = ':TSUpdate',
    -- 2. Use 'init' for filetype detection (as before)
    init = function()
      vim.filetype.add {
        extension = { mdx = 'mdx', gowork = 'gowork', gotmpl = 'gotmpl', kdl = 'kdl' },
        filename = { ['go.work'] = 'gowork', ['go.mod'] = 'gomod' },
      }
    end,

    -- 3. The New Configuration Logic
    config = function()
      local ts = require('nvim-treesitter')

      ts.setup {
        install_dir = vim.fn.stdpath('data') .. '/site',
      }

      -- MANAGE PARSERS: Use the new 'install' function directly
      ts.install({
        'bash',
        'vim',
        'regex',
        'html',
        'latex',
        'yaml',
        'go',
        'java',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'rust',
        'sql',
        'cpp',
        'cmake',
        'kdl',
      }):wait(300000) -- wait max. 5 minutes

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local bufnr = args.buf
          -- Optimization: Use the buffer number directly
          local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) or vim.bo[bufnr].filetype

          if pcall(vim.treesitter.start, bufnr, lang) then
            -- FOLDS: Buffer-local settings
            vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local' })
            vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.treesitter.foldexpr()', { scope = 'local' })
            vim.api.nvim_set_option_value('foldlevel', 99, { scope = 'local' })

            -- INDENTATION
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- BUILT-IN TOOLS (Standard Neovim commands)
      local keymap = vim.keymap.set
      keymap('n', '<leader>it', '<cmd>InspectTree<cr>', { desc = 'Inspect Tree' })
      keymap('n', '<leader>ih', '<cmd>Inspect<cr>', { desc = 'Inspect Highlights' })
    end,
  },

  -- 4. Textobjects must also be on the 'main' branch
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    lazy = true,
  },
}
