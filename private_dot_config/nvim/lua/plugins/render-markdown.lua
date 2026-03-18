return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- 1. Use 'init' for settings that affect the buffer before the plugin loads
    init = function()
      vim.opt.conceallevel = 2
    end,
    -- 2. Pure data table. No logic here.
    opts = {
      heading = {
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        foregrounds = {
          'CatppuccinBlue',
          'CatppuccinPeach',
          'CatppuccinGreen',
          'CatppuccinMauve',
          'CatppuccinRed',
          'CatppuccinYellow',
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
    },
    -- 3. We keep 'config' only because we are doing extra Lua work (highlight linking)
    config = function(_, opts)
      require('render-markdown').setup(opts)
      vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { link = 'NormalFloat', default = true })
    end,
  },
}
