return {
  { "tpope/vim-fugitive" },
  { "ojroques/nvim-osc52" },
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
