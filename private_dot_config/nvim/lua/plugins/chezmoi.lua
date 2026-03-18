return {
  'xvzc/chezmoi.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>cz',
      function()
        -- The modern way to call the picker (Telescope, Snacks, or Fzf-lua)
        require('chezmoi.pick').telescope()
      end,
      desc = 'Chezmoi: Search managed files',
    },
  },
  config = function()
    require('chezmoi').setup {
      edit = {
        watch = false,
        force = false,
        ignore_patterns = {
          'run_onchange_.*',
          'run_once_.*',
          '%.chezmoiignore',
          '%.chezmoitemplate',
        },
      },
      events = {
        on_open = {
          notification = {
            enable = true,
            msg = 'Opened a chezmoi-managed file',
            opts = {},
          },
        },
        on_watch = {
          notification = {
            enable = true,
            msg = 'This file will be automatically applied',
            opts = {},
          },
        },
        on_apply = {
          notification = {
            enable = true,
            msg = 'Successfully applied',
            opts = {},
          },
        },
      },
      telescope = {
        select = { '<CR>' },
      },
    }

    -- AUTOMATIC APPLY-ON-SAVE
    -- This block detects if you are inside your chezmoi source directory
    -- and tells chezmoi.nvim to "watch" the buffer.
    -- When you save (:w), it automatically runs 'chezmoi apply'.
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      pattern = { os.getenv('HOME') .. '/.local/share/chezmoi/*' },
      callback = function(ev)
        local bufnr = ev.buf
        local edit_watch = function()
          require('chezmoi.commands.__edit').watch(bufnr)
        end
        vim.schedule(edit_watch)
      end,
    })
  end,
}
