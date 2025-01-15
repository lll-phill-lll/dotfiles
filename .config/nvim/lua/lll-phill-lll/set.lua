vim.o.background = 'dark'

vim.cmd([[colorscheme tokyonight-storm]])

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

-- vim.opt.colorcolumn = "120"

-- Fix stupid tab
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Open splint on right or below
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.completeopt="menu"

vim.o.termguicolors = true

vim.cmd("highlight clear StatusLine")
-- vim.opt.laststatus = 0

-- allow trailing spaces https://www.reddit.com/r/neovim/comments/17ak2eq/neovim_is_automatically_removing_trailing/
vim.g.editorconfig = false
vim.opt.signcolumn = "no"
