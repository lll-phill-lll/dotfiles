-- Default nvim mappings.
-- To see mapping related to plugins navigate to after/plugged/<plugin name>
vim.g.mapleader = ","

silentNoremap = function(mode, from, to)
    vim.api.nvim_set_keymap(mode, from, to, { noremap=true, silent=true })
end

-- Save file and exit Insert mode by pressing "jk" or "kj"
silentNoremap('i', 'jk', '<Esc> :w <CR>k')
silentNoremap('i', 'kj', '<Esc> :w <CR>k')


-- While editing long lines change "displayed" line instead of "real" line while pressing j or k 
silentNoremap('n', 'j', 'gj')
silentNoremap('n', 'k', 'gk')

-- Save and quit files with Q and W
vim.api.nvim_create_user_command('W', 'w', { force = true })
vim.api.nvim_create_user_command('Q', 'q', { force = true })

-- Navigate tabs
silentNoremap('n', '<leader>1', '1gt')
silentNoremap('n', '<leader>2', '2gt')
silentNoremap('n', '<leader>3', '3gt')
silentNoremap('n', '<leader>4', '4gt')
silentNoremap('n', '<leader>5', '5gt')
silentNoremap('n', '<leader>6', '6gt')
silentNoremap('n', '<leader>7', '7gt')
silentNoremap('n', '<leader>8', '8gt')
silentNoremap('n', '<leader>9', '9gt')
silentNoremap('n', '<leader>0', ':tablast<CR>')

silentNoremap('n', '<leader>rr', '<cmd>source ~/.config/nvim/init.lua<CR>')

-- Move highlighted group
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in the middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Move half sreen up/down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Fixes appending strings
vim.keymap.set("n", "J", "mzJ`z")

