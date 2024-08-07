-- Telescope (fuzzy finder)
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
vim.keymap.set('n', '<leader>rg', builtin.live_grep, {})

vim.keymap.set('n', '<leader>lf', function () builtin.lsp_document_symbols() end, {})
