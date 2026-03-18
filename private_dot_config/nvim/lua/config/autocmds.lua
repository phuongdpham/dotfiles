-- Auto-save when switching away from Neovim (requires tmux set-option -g focus-events on)
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == '' then
      vim.cmd('silent! wall')
    end
  end,
})
