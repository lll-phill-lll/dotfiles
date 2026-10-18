local M = {}
local modern = vim.fn.has('nvim-0.12') == 1
local languages = { 'c', 'cpp', 'lua', 'vim', 'vimdoc', 'query', 'rust', 'python' }

function M.setup()
    if not modern then
        require('nvim-treesitter.configs').setup({
            ensure_installed = languages,
            sync_install = false,
            auto_install = false,
            highlight = { enable = true, additional_vim_regex_highlighting = false },
        })
        return
    end

    require('nvim-treesitter').setup({ install_dir = vim.fn.stdpath('data') .. '/site' })
    vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('DotfilesTreesitter', { clear = true }),
        callback = function(event)
            local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
            -- Filetypes without an installed parser keep Vim's highlighting.
            if lang and #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0 then
                vim.treesitter.start(event.buf, lang)
            end
        end,
    })
end

-- Called by the installer, so parser compilation finishes before nvim exits.
function M.install()
    if not modern then
        vim.cmd('TSInstallSync ' .. table.concat(languages, ' '))
        vim.cmd('TSUpdateSync')
        return
    end

    assert(vim.fn.executable('tree-sitter') == 1,
        'Tree-sitter CLI is missing. Run ./run.sh to install the dependencies.')
    local treesitter = require('nvim-treesitter')
    treesitter.setup({ install_dir = vim.fn.stdpath('data') .. '/site' })
    assert(treesitter.update():wait(300000), 'Tree-sitter parser update failed')
    assert(treesitter.install(languages):wait(300000), 'Tree-sitter parser installation failed')
    local installed = {}
    for _, lang in ipairs(treesitter.get_installed('parsers')) do installed[lang] = true end
    for _, lang in ipairs(languages) do
        assert(installed[lang], 'Tree-sitter parser installation failed: ' .. lang)
    end
end

return M
