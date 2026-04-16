vim.filetype.add {
    extension = {
        tmpl = 'gotmpl',
    'norg',
        work = 'gowork',
    },
    filename = {
        ['go.work'] = 'gowork',
    },
}

-- Enable 0.12 UI2 features (virtually eliminates blocking message prompts)
pcall(function()
    require('vim._core.ui2').enable {}
end)

-- Load core modules
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- Load plugins via 0.12 native package manager
require('core.plugins')

-- Native LSP configurations
require('core.lsp')
