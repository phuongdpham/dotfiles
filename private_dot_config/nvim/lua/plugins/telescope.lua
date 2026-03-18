return {
  {
    'nvim-telescope/telescope.nvim',
    -- Use 'keys' for lazy-loading. Telescope won't load until you press these.
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find Files' },
      { '<leader>fo', '<cmd>Telescope oldfiles<cr>', desc = 'Old Files' },
      { '<leader>fq', '<cmd>Telescope quickfix<cr>', desc = 'Quickfix' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help Tags' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
      -- Complex functions can be wrapped in Lua functions here
      {
        '<leader>fg',
        function()
          require('telescope.builtin').grep_string { search = vim.fn.input('Grep > ') }
        end,
        desc = 'Grep String',
      },
      {
        '<leader>fc',
        function()
          require('telescope.builtin').grep_string { search = vim.fn.expand('%:t:r') }
        end,
        desc = 'Find current file',
      },
      {
        '<leader>fs',
        function()
          require('telescope.builtin').grep_string {}
        end,
        desc = 'Find current string',
      },
      {
        '<leader>fi',
        function()
          require('telescope.builtin').find_files { cwd = '~/.config/nvim/' }
        end,
        desc = 'Find in config',
      },
    },
    opts = {
      defaults = {
        -- Your custom telescope settings go here
      },
    },
    config = function(_, opts)
      require('telescope').setup(opts)
    end,
  },
}
