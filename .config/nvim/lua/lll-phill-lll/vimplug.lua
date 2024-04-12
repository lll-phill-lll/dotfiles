local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

-- Telescope (fuzzy finder)
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })

-- Gruvbox (colorscheme)
Plug('ellisonleao/gruvbox.nvim')

-- Treesitter (better syntax highlighting)
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = function()
  vim.fn['TSUpdate']()
end })

-- Show the tree of all changes. Persistent storage (undo also after nvim reload)
Plug('mbbill/undotree')

-- Default configs for lsp
Plug('neovim/nvim-lspconfig')

vim.call('plug#end')
