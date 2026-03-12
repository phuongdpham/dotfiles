return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require('harpoon')

    harpoon:setup {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    }

    vim.keymap.set('n', '<leader>h', function()
      harpoon:list():add()
    end, { desc = 'Harpoon add file' })
    vim.keymap.set('n', '<leader>rm', function()
      harpoon:list():remove()
    end, { desc = 'Remove current file from Harpoon' })
    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)
    vim.keymap.set('n', '<C-p>', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<C-n>', function()
      harpoon:list():next()
    end)

    -- basic telescope configuration
    local function toggle_telescope(harpoon_files)
      local conf = require('telescope.config').values
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>fl', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })

    -- vim.keymap.set('n', '<leader>fl', function()
    --   local conf = require('telescope.config').values
    --   local themes = require('telescope.themes')
    --   local file_paths = {}
    --   for _, item in ipairs(harpoon:list().items) do
    --     table.insert(file_paths, item.value)
    --   end
    --   require('telescope.pickers')
    --     .new(themes.get_ivy { prompt_title = 'Working List' }, {
    --       finder = require('telescope.finders').new_table { results = file_paths },
    --       previewer = conf.file_previewer {},
    --       sorter = conf.generic_sorter {},
    --     })
    --     :find()
    -- end, { desc = 'Open harpoon window' })
  end,
}
