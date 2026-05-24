-- Set leader key to space (Must be at the very top!)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local set = vim.opt

set.shell = '/usr/bin/fish'

-- Spacing & Search
set.tabstop = 4
set.shiftwidth = 4
set.autoindent = true
set.expandtab = true
set.ignorecase = true
set.smartcase = true

-- Appearance
set.relativenumber = true
set.number = true
set.termguicolors = true
set.background = 'dark'
set.signcolumn = 'yes'
set.cursorline = true
set.colorcolumn = '80'
set.scrolloff = 8
set.splitbelow = true
set.splitright = true

-- System Clipboard
set.clipboard:append('unnamedplus')

-- Native 0.12 Undo Engine
set.swapfile = false
set.backup = false
set.undodir = os.getenv('HOME') .. '/.vim/undodir'
set.undofile = true

-- Performance
set.updatetime = 50
set.timeoutlen = 300

set.laststatus = 3
set.showmode = false
set.termguicolors = true

set.modelines = 0
