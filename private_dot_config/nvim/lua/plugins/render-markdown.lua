return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  opts = {
    heading = {
      -- Use "Glow" style headers that match Catppuccin colors
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
  config = function(_, opts)
    require('render-markdown').setup(opts)

    -- Link the background color to Catppuccin Surface
    -- This fixes the error and sets the color in one go
    vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { link = 'NormalFloat' }) -- Or use a specific hex

    -- Ensure Neovim's conceal settings are correct for the plugin to work
    vim.opt.conceallevel = 2
  end,
}
