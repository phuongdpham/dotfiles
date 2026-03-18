return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    -- 1. Use 'keys' for true lazy-loading. Harpoon won't load until you use it.
    keys = {
      {
        '<leader>h',
        function()
          require('harpoon'):list():add()
        end,
        desc = 'Harpoon Add File',
      },
      {
        '<leader>rm',
        function()
          require('harpoon'):list():remove()
        end,
        desc = 'Harpoon Remove File',
      },
      {
        '<C-e>',
        function()
          local h = require('harpoon')
          h.ui:toggle_quick_menu(h:list())
        end,
        desc = 'Harpoon Menu',
      },
      {
        '<C-p>',
        function()
          require('harpoon'):list():prev()
        end,
        desc = 'Harpoon Previous',
      },
      {
        '<C-n>',
        function()
          require('harpoon'):list():next()
        end,
        desc = 'Harpoon Next',
      },
      -- Integrated Telescope Picker
      {
        '<leader>fl',
        function()
          local harpoon = require('harpoon')
          local conf = require('telescope.config').values
          local file_paths = {}
          for _, item in ipairs(harpoon:list().items) do
            table.insert(file_paths, item.value)
          end

          require('telescope.pickers')
            .new({}, {
              prompt_title = 'Harpoon',
              finder = require('telescope.finders').new_table { results = file_paths },
              previewer = conf.file_previewer {},
              sorter = conf.generic_sorter {},
            })
            :find()
        end,
        desc = 'Telescope Harpoon List',
      },
    },
    -- 2. opts table for configuration
    opts = {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    },
    -- 3. We use the default config() which calls require("harpoon").setup(opts)
  },
}
