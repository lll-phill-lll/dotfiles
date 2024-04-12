vim.o.background = 'light'

vim.cmd([[colorscheme gruvbox]])

-- Always use rectangle as a cursor
vim.opt.guicursor = ""
-- Disable mouse
vim.opt.mouse = ""

-- Disable swap files
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.termguicolors = true

-- Show line numbers on the left
vim.opt.number = true
-- Show relative numbers to the cursor position
vim.opt.relativenumber = true

-- Better search highlighting
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- While scrolling keep 10 lines on screen
vim.opt.scrolloff = 10

vim.opt.updatetime = 50

vim.opt.colorcolumn = "120"

-- Fix stupid tab
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
