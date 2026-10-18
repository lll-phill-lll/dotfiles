vim.o.background = 'dark'

require("tokyonight").setup({
transparent = true,
tokyonight_dark_float = false;
})

vim.cmd([[colorscheme tokyonight-storm]])
vim.g.tokyonight_dark_float = false

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
-- show signs (marks in my case) in numbers column
vim.opt.signcolumn = "number"

vim.cmd([[
  set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
]])


if vim.g.neovide then
  vim.g.neovide_opacity = 0.85
  vim.g.neovide_input_macos_option_key_is_meta = "both"
  vim.o.guifont = "Iosevka"
  vim.opt.clipboard = "unnamedplus"
  vim.g.neovide_macos_simple_fullscreen = true
end
if vim.g.neovide then
  vim.keymap.set({ "n", "v" }, "<D-v>", '"+p', { silent = true })
  vim.keymap.set("i", "<D-v>", '<C-r>+', { silent = true })
  vim.keymap.set("c", "<D-v>", '<C-r>+', { silent = true })

  vim.keymap.set({ "n", "v" }, "<D-c>", '"+y')
  vim.keymap.set("i", "<D-c>", '<Esc>"+yiw', { silent = true })
    vim.g.neovide_scale_factor = 1.0

  local function scale(delta)
    vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) * delta
  end

  -- На macOS "+" = Shift + "=" → маппим оба варианта
  vim.keymap.set("n", "<D-=>", function() scale(1.10) end, { silent = true })
  vim.keymap.set("n", "<D-S-=>", function() scale(1.10) end, { silent = true })
  vim.keymap.set("n", "<D-->", function() scale(1/1.10) end, { silent = true })
  vim.keymap.set("n", "<D-0>", function() vim.g.neovide_scale_factor = 1.0 end, { silent = true })
end

vim.keymap.set("n", "<D-t>", function()
  if vim.bo.buftype == "terminal" then
    vim.cmd("bd!")
  else
    vim.cmd("split | terminal")
  end
end)



