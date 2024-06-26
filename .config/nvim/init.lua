require('lll-phill-lll')





--+-----------------------------------------------------+--
--+--+--+--+--+--+--+--+-- HINTS --+--+--+--+--+--+--+--+--
--+-----------------------------------------------------+--

-- vim-plug vill automatically source all files in after/plugin directory so you may put cvomfigs of plugins there

-- gR                - vim - vreplace
-- :%retab           - vim - Change tabs
-- ,cc               - vim - comment line
-- ,cu               - vim - uncomment line
-- <C-c>             - vim - compile
-- :find *cp         - vim - find files in a project ending in cp
-- :b uniq           - vim - open recent file with unique symbols providen
-- ^]                - vim+ctags - go to declaration
-- g^]               - vim+ctags - find each instance of variable
-- ^t                - vim+ctags - jump back
-- ^x^n              - vim - find in current file
-- ^x^f              - vim - find files (with wildcards)
-- ^x^]              - vim - find in tags
-- ^n                - vim - find anything
-- :Sex              - vim - explore dir with horizontal split
-- :Vex              - vim - explore dir with vertical split
-- :noh              - vim - disable highlight for cirrent search
-- С^                - vim - change keymap
-- T,F               - vim - same as t,f but move backwards
-- P                 - vim - paste before the cursor
-- ab                - vim - visual block in () (works in visual mode)
-- aB                - vim - visual block in {} (works in visual mode)
-- o                 - vim - move to block corner (works in visual mode)
-- O                 - vim - move to OTHER block corner (works in visual mode)
-- Ctrl-y            - vim - Moves screen up one line
-- Ctrl-e            - vim - Moves screen down one line
-- Ctrl-u            - vim - Moves cursor & screen up ½ page
-- Ctrl-d            - vim - Moves cursor & screen down ½ page
-- Ctrl-b            - vim - Moves screen up one page, cursor to last line
-- Ctrl-f            - vim - Moves screen down one page, cursor to first line
-- Ctrl-y            - vim - and Ctrl-e only change the cursor position if it would be moved off screen.
-- zz                - vim - move current line to the middle of the screen
-- zt                - vim - move current line to the top of the screen
-- zb                - vim - move current line to the bottom of the screen
-- :so               - vim - reload config
--
--
--
-- Tabs:
-- :tabmove +2       - vim - move surrent tab 2 position right
-- N + gt            - vim - go to tab number N
--
-- :set nospell      - vim - disable spelling
-- ]s                - vim - next word with mistake
-- [s                - vim - prev work with mistake
-- z=                - vim - change word from list
-- zg                - vim - good word
-- zw                - vim - wrong word
-- zG                - vim - ignore word
-- zz                - vim - center the screen
-- set cursorcolumn  - vim - set cursorcolumn
--
-- gh                - vim - show/hide hidden files in netrw
-- C-v + {<,>,+,-}   - vim - change split size
--
--
-- gS                - splitJoin - split struct declaration
-- gJ                - splitJoin - join struct declaratin
-- :GoImports        - vim-go - autoImports and deletes imports
-- :UltiSnipsEdit    - ultisnips - open file with snippet scripts
-- gd                - vim-go - go to declaration
-- ctrl+t            - vim-go - go back from declaration
-- :GoDefStack       - vim-go - show stack of locations for gd
-- :GoDefStackClear  - vim-go - clear stack for gd
-- :GoDecls          - vim-go - see all the declaration in file
-- :GoDeclsDir       - vim-go - see all declarations in directory
-- K                 - vim-go - see documentation and signature
-- :GoChannelPeers   - vim-go - shows channel recievers and senders
-- :GoCallees        - vim-go - get all possible implememtation of given anon function
-- :GoCallers        - vim-go - get all possible callers of given function
-- :GoImpl + interfac- vim-go - create implementation of interface
-- :GoPlay           - vim-go - open in go playground
--
-- cmd+/             - iterm - find cursor position
--
--
-- https://vim.fandom.com/wiki/Using_marks
-- snippets in go.snippets
-- install gotags https://github.com/jstemmer/gotags
