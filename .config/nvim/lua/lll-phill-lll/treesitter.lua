local M = {}
local modern = vim.fn.has('nvim-0.12') == 1
local languages = { 'asm', 'c', 'cpp', 'lua', 'vim', 'vimdoc', 'query', 'rust', 'python' }

function M.setup()
    vim.filetype.add({ extension = { S = 'asm', s = 'asm' } })
    if not modern then
        require('nvim-treesitter.configs').setup({
            ensure_installed = languages,
            sync_install = false,
            auto_install = true,
            highlight = { enable = true, additional_vim_regex_highlighting = false },
        })
        return
    end

    local treesitter = require('nvim-treesitter')
    treesitter.setup({ install_dir = vim.fn.stdpath('data') .. '/site' })
    local available = {}
    for _, lang in ipairs(treesitter.get_available()) do available[lang] = true end
    local installing = {}

    local function buffer_language(buf)
        if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then return end
        return vim.treesitter.language.get_lang(vim.bo[buf].filetype)
    end

    local function has_parser(lang)
        return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
    end

    local function attach(buf)
        local lang = buffer_language(buf)
        if not lang then return end
        if has_parser(lang) then
            vim.treesitter.start(buf, lang)
            return
        end
        -- Unsupported filetypes keep Vim's highlighting. Share one install
        -- between all buffers using the same language.
        if not available[lang] or installing[lang] then return end
        installing[lang] = true
        treesitter.install({ lang }):await(function(err, success)
            vim.schedule(function()
                installing[lang] = nil
                if err or not success or not has_parser(lang) then
                    vim.notify('Treesitter: failed to install ' .. lang .. (err and (': ' .. tostring(err)) or ''),
                        vim.log.levels.ERROR)
                    return
                end
                -- Buffers may have been closed or changed filetype while
                -- the parser was downloading. Attach only matching buffers.
                for _, open_buf in ipairs(vim.api.nvim_list_bufs()) do
                    if buffer_language(open_buf) == lang then
                        vim.treesitter.start(open_buf, lang)
                    end
                end
            end)
        end)
    end

    vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('DotfilesTreesitter', { clear = true }),
        callback = function(event) attach(event.buf) end,
    })
    -- Also cover buffers whose FileType event ran before this setup.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do attach(buf) end
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
