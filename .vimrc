" required vim with python3 support
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'Yggdroot/indentLine'
Plug 'dhruvasagar/vim-table-mode'
Plug 'mhinz/vim-startify'
call plug#end()

colorscheme gruvbox

" Default settings:
" -------------------------------------
set background=dark
" set encoding=utf-8
set encoding=cp1251
" symbol to start special commands
let g:mapleader=','
set noswapfile

" for fuzzy file search
set path+=**
set wildmenu

" remap esc to jk
inoremap jk <Esc> :w <CR>
inoremap kj <Esc> :w <CR>

if has("gui_running")
    set termguicolors
endif

filetype plugin indent on
set backspace=indent,eol,start
" show existing tab with 4 spaces width
" when indenting with '>', use 4 spaces width
set shiftwidth=4
set number
set hlsearch	" highlight search results
set incsearch 	" increment search

set tabstop=4

set ai
set cin
set smarttab
set expandtab
set smartindent
syntax on

:command! Q q
:command! W w

" -------------------------------------


" status line
" -------------------------------------
function! ArcBranch()
      return  substitute(system("arc branch 2>/dev/null | grep '\*' | cut -f2 -d' ' | sed -e 's#^users/.*/##'"), '\n', '', 'g')
endfunction

function! GitBranch()
      return  substitute(system("git branch 2>/dev/null | grep '\*' | cut -f2 -d' ' | sed -e 's#^users/.*/##'"), '\n', '', 'g')
endfunction

set laststatus=2
augroup gitstatusline
    au!
    " :help autocmd-events-abc
    autocmd BufWritePre,BufEnter * let b:arc_status = ArcBranch()
    autocmd BufWritePre,BufEnter * let b:git_status = GitBranch()
augroup end

let &statusline = '[%{get(b:, "arc_status", "")}%{get(b:, "git_status", "")}]'

set statusline+=%<\                       " cut at start
set statusline+=%-40f\                    " path
set statusline+=%=%y%*%*\                 " file type
set statusline+=%10((%l,%c)%)\            " line and column
set statusline+=%P
" -------------------------------------
" status line end



" compile and run
" -------------------------------------
autocmd filetype cpp nnoremap <C-c> :w <bar> !clear && g++ -std=gnu++14 -O0 % -o %:h/%:t:r.lol && ./%:r.lol<CR>

autocmd filetype c nnoremap <C-c> :w <bar> !clear && gcc -pthread -lm -fopenmp % -o %:p:h/%:t:r.lol && ./%:r.lol<CR>
autocmd filetype c nnoremap <C-k> :w <bar> !clear && gcc -c  % && gcc %:h/%:t:r.o -fopenmp -lglpk -lgmp -lm -o %:h/%:t:r.lol && ./%:r.lol<CR>

autocmd filetype java nnoremap <C-c> :w <bar> !javac % && java -enableassertions %:p <CR>
autocmd filetype python nnoremap <C-c> :w <bar> !python3 % <CR>
autocmd filetype haskell nnoremap <C-c> :w <bar> !ghci % <CR>
autocmd filetype perl nnoremap <C-c> :w <bar> !perl % <CR>
autocmd filetype go nnoremap <C-c> :w <bar> !go build % && ./%:p <CR>
" -------------------------------------
" end compile and run


" brackets matching:
" -------------------------------------
" #macsuck
if has('mac')
    inoremap {<CR> {<CR>}<esc>ko
else
    inoremap {<CR> {<CR>}<esc>ko<tab>
endif

autocmd filetype cpp,c,java,go,python,haskell,perl,scala inoremap {<CR> {<CR>}<esc>ko
inoremap [<CR> []<esc>i
inoremap (<CR> ()<esc>i
inoremap "<CR> ""<esc>i
inoremap '<CR> ''<esc>i
" -------------------------------------
" end brackets matching

" netrw settings | help netrw-browse-maps
" -------------------------------------
let g:netrw_banner = 0 " disable banner
let g:netrw_liststyle = 3 " tree view of folders
let g:netrw_browse_split = 3 " open file in a new tab
let g:netrw_winsize = 40 " size of split
let g:netrw_keepdir=1
" -------------------------------------
" end netrw settings

" commenting blocks of code.
" -------------------------------------
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,java,scala,go let b:comment_leader = '// '
  autocmd FileType sh,ruby,python      let b:comment_leader = '# '
  autocmd FileType conf,fstab          let b:comment_leader = '# '
  autocmd FileType tex                 let b:comment_leader = '% '
  autocmd FileType mail                let b:comment_leader = '> '
  autocmd FileType vim                 let b:comment_leader = '" '
augroup END
noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
" -------------------------------------
" end commenting blocks of code.

" ident line (disabled by default) <leader> + il to enable
let g:indentLine_enabled = 0
let g:indentLine_color_term = 239
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
nnoremap <leader>il :IndentLinesToggle<CR>


set relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

inoreabbrev <expr> <bar><bar>
          \ <SID>isAtStartOfLine('\|\|') ?
          \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
          \ <SID>isAtStartOfLine('__') ?
          \ '<c-o>:silent! TableModeDisable<cr>' : '__'

"Rest tables
let g:table_mode_corner_corner='+'
let g:table_mode_corner='+'
let g:table_mode_header_fillchar='='



" Commands:
command! -nargs=+ Sub call Sub(<f-args>)
function! Sub( ... )
        execute printf('%%substitute/%s/%s/gr', a:1, a:2)
    endfunction

" requires installed ctags
" for shitty macos default ctags:
" $ brew install ctags
" $ alias ctags="`brew --prefix`/bin/ctags"
" for modern languages eg go:
" brew tap universal-ctags/universal-ctags
" brew install --HEAD universal-ctags
" https://docs.ctags.io/en/latest/osx.html#building-with-homebrew
" #macsuck
if has('mac')
    :command! MakeTags !`brew --prefix`/bin/ctags -R .
else
    :command! MakeTags !ctags -R .
endif
set tags=tags

"set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
"put keymap into a folder ~/.vim/keymap
if has('mac')
    set keymap=russian-jcukenmac
    set iminsert=0
    set imsearch=0
endif

"punctuation
"mkdir -p ~/.vim/spell
"    cd ~/.vim/spell
"    wget http://ftp.vim.org/vim/runtime/spell/ru.koi8-r.sug
"    wget http://ftp.vim.org/vim/runtime/spell/ru.koi8-r.spl
"    wget http://ftp.vim.org/vim/runtime/spell/en.ascii.sug
"    wget http://ftp.vim.org/vim/runtime/spell/en.ascii.spl

" treat each file as md in this folder
autocmd BufRead,BufNewFile ~/discclub set filetype=markdown

" enable spelling in some files
autocmd FileType tex,latex,markdown set spell spelllang=ru,en

" remove trailing spaces while saving
autocmd BufWritePre * %s/\s\+$//e

function! MakeClangFormat()
  if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
    let cursor_pos = getpos('.')
    :%!clang-format-13
    call setpos('.', cursor_pos)
  endif
endfunction

autocmd BufWritePre *.h,*.hpp,*.c,*.cpp, :call MakeClangFormat()

nnoremap <leader>s :setlocal spell! spelllang=ru,en<CR>

nnoremap <leader>b i<b><esc>
nnoremap <leader>g i<g><esc>

autocmd BufRead,BufNewFile *.stc set filetype=cel
autocmd BufRead,BufNewFile *.gl set filetype=goals

function! Inc(x)
    let a:x[0] += 1
    return a:x[0]
endfunction



" Tabs navigation
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>



" Instructions:
" gR                - vim - vreplace
" :%retab           - vim - Change tabs
" ,cc               - vim - comment line
" ,cu               - vim - uncomment line
" <C-c>             - vim - compile
" :find *cp         - vim - find files in a project ending in cp
" :b uniq           - vim - open recent file with unique symbols providen
" ^]                - vim+ctags - go to declaration
" g^]               - vim+ctags - find each instance of variable
" ^t                - vim+ctags - jump back
" ^x^n              - vim - find in current file
" ^x^f              - vim - find files (with wildcards)
" ^x^]              - vim - find in tags
" ^n                - vim - find anything
" :Sex              - vim - explore dir with horizontal split
" :Vex              - vim - explore dir with vertical split
" :noh              - vim - disable highlight for cirrent search
" С^                - vim - change keymap
" T,F               - vim - same as t,f but move backwards
" P                 - vim - paste before the cursor
" ab                - vim - visual block in () (works in visual mode)
" aB                - vim - visual block in {} (works in visual mode)
" o                 - vim - move to block corner (works in visual mode)
" O                 - vim - move to OTHER block corner (works in visual mode)
"
" Tabs:
" :tabmove +2       - vim - move surrent tab 2 position right
" N + gt            - vim - go to tab number N
"
" :set nospell      - vim - disable spelling
" ]s                - vim - next word with mistake
" [s                - vim - prev work with mistake
" z=                - vim - change word from list
" zg                - vim - good word
" zw                - vim - wrong word
" zG                - vim - ignore word
" zz                - vim - center the screen
" set cursorcolumn  - vim - set cursorcolumn
"
" gh                - vim - show/hide hidden files in netrw
" C-v + {<,>,+,-}   - vim - change split size
"
"
" gS                - splitJoin - split struct declaration
" gJ                - splitJoin - join struct declaratin
" :GoImports        - vim-go - autoImports and deletes imports
" :UltiSnipsEdit    - ultisnips - open file with snippet scripts
" gd                - vim-go - go to declaration
" ctrl+t            - vim-go - go back from declaration
" :GoDefStack       - vim-go - show stack of locations for gd
" :GoDefStackClear  - vim-go - clear stack for gd
" :GoDecls          - vim-go - see all the declaration in file
" :GoDeclsDir       - vim-go - see all declarations in directory
" K                 - vim-go - see documentation and signature
" :GoChannelPeers   - vim-go - shows channel recievers and senders
" :GoCallees        - vim-go - get all possible implememtation of given anon function
" :GoCallers        - vim-go - get all possible callers of given function
" :GoImpl + interfac- vim-go - create implementation of interface
" :GoPlay           - vim-go - open in go playground
"
" cmd+/             - iterm - find cursor position
"
"
" https://vim.fandom.com/wiki/Using_marks
" snippets in go.snippets
" install gotags https://github.com/jstemmer/gotags
"
