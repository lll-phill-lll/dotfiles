-- Telescope (fuzzy finder)
local builtin = require('telescope.builtin')


vim.api.nvim_set_hl(0,"TelescopeNormal",{bg="none"})
vim.api.nvim_set_hl(0,"TelescopeBorder",{bg="none"})
vim.api.nvim_set_hl(0,"TelescopePromptBorder",{bg="none"})
vim.api.nvim_set_hl(0,"TelescopePromptTitle",{bg="none"})


vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
vim.keymap.set('n', '<leader>rg', builtin.live_grep, {})

vim.keymap.set('n', '<leader>lf', function () builtin.lsp_document_symbols() end, {})
vim.keymap.set('n', '<leader>fm', function () builtin.marks() end, {})
