-- nvim-lspconfig supplies server definitions; Neovim 0.11+ configures them.
vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('DotfilesLsp', { clear = true }),
    callback = function(event)
        local bufnr = event.buf
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local function map(mode, key, action)
            vim.keymap.set(mode, key, action, { buffer = bufnr, silent = true })
        end
        map('n', 'gD', vim.lsp.buf.declaration)
        map('n', 'gd', vim.lsp.buf.definition)
        map('n', 'K', vim.lsp.buf.hover)
        map('n', 'gi', vim.lsp.buf.implementation)
        map('n', 's', vim.lsp.buf.signature_help)
        map('i', '<leader>s', vim.lsp.buf.signature_help)
        map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder)
        map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder)
        map('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
        map('n', '<leader>D', vim.lsp.buf.type_definition)
        map('n', '<leader>rn', vim.lsp.buf.rename)
        map('n', '<leader>qf', vim.lsp.buf.code_action)
        map('n', 'gr', vim.lsp.buf.references)
        map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end)
        map('n', '<leader>e', vim.diagnostic.open_float)
        map('n', 'ge', function() vim.diagnostic.jump({ count = 1, float = true }) end)
        map('n', 'gE', function() vim.diagnostic.jump({ count = -1, float = true }) end)
        map('n', '<leader>q', vim.diagnostic.setloclist)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.name == 'clangd' then
            map('n', '<leader>hh', '<cmd>LspClangdSwitchSourceHeader<CR>')
        end
    end,
})

vim.lsp.config('rust_analyzer', { settings = { ['rust-analyzer'] = {} } })
vim.lsp.config('clangd', {
    cmd = {
        'clangd',
        '--background-index',
        '--pch-storage=memory',
        '--all-scopes-completion',
        '--pretty',
        '--header-insertion=never',
        '-j=64',
        '--header-insertion-decorators',
        '--function-arg-placeholders',
        '--completion-style=detailed',
    },
})
vim.lsp.enable({ 'pyright', 'rust_analyzer', 'clangd' })
