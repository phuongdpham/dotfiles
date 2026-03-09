return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    local npairs = require('nvim-autopairs')
    npairs.setup {
      check_ts = true, -- Enable Tree-sitter integration
      enable_check_bracket_line = false, -- Don't add pairs if it already has a close pair in the same line
    }
  end,
}
