return {
  { "tpope/vim-fugitive" },
  { "ojroques/nvim-osc52" },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
