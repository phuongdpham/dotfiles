return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      -- Manual format trigger for when you don't want to save
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  opts = {
    -- Define your formatters by filetype
    formatters_by_ft = {
      -- Niri Configuration
      -- kdl = { 'kdlfmt' },

      -- General Arch/Linux development
      lua = { 'stylua' },
      fish = { 'fish_indent' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      rust = { 'rustfmt' },

      -- Fallback for everything else (using Prettier if installed)
      ['_'] = { 'trim_whitespace' },
    },

    -- Custom formatter configuration (if needed)
    formatters = {
      shfmt = {
        prepend_args = { '-i', '2' }, -- 2-space indent for shell scripts
      },
      -- kdlfmt = {
      --   -- Tell kdlfmt not to be too aggressive with certain KDL features
      --   -- Some versions of kdlfmt support a --check flag or specific indent sizes
      --   args = { 'format', '-' },
      -- },
    },
  },
}
