local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

-- Telescope (fuzzy finder)
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })

-- Gruvbox (colorscheme)
Plug('ellisonleao/gruvbox.nvim')
-- TokioNight (colorscheme)
Plug('folke/tokyonight.nvim')

-- Treesitter (better syntax highlighting)
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = function()
  vim.fn['TSUpdate']()
end })

-- Show the tree of all changes. Persistent storage (undo also after nvim reload)
Plug('mbbill/undotree')

-- Default configs for lsp
Plug('neovim/nvim-lspconfig')

-- Show context of functions
Plug('nvim-treesitter/nvim-treesitter-context')

-- Move across objects easely
Plug('nvim-treesitter/nvim-treesitter-textobjects')

Plug('karb94/neoscroll.nvim')

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'

Plug 'chentoast/marks.nvim'

vim.call('plug#end')
