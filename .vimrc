call plug#begin('~/.vim/plugged')
" colorschemas
Plug 'morhetz/gruvbox'
Plug 'fatih/molokai'

call plug#end()


let $PATH='$HOME/.cargo/bin:/usr/bin:/usr/local/bin:/bin:/usr/sbin:/sbin'
colorscheme gruvbox

set background=dark
set encoding=utf-8
let g:mapleader=','
set noswapfile

set relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

filetype plugin indent on
set backspace=indent,eol,start
" show existing tab with 4 spaces width
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
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

inoremap {<CR> {<CR>}<esc>ko<tab>
autocmd filetype cpp,c,java,go,python,haskell,perl inoremap {<CR> {<CR>}<esc>ko
inoremap [<CR> []<esc>i
inoremap (<CR> ()<esc>i
inoremap "<CR> ""<esc>i
inoremap '<CR> ''<esc>i


" set clipboard=unnamedplus

autocmd filetype cpp nnoremap <C-c> :w <bar> !clear && g++ -std=gnu++14 -O0 % -o %:h/%:t:r.exe && ./%:r.exe<CR>
" mb add :p before :h/%:t...

autocmd filetype c nnoremap <C-c> :w <bar> !clear && gcc -pthread -lm % -o %:p:h/%:t:r.exe && ./%:r.exe<CR>
autocmd filetype c nnoremap <C-k> :w <bar> !clear && gcc -c  % && gcc %:h/%:t:r.o -lglpk -lgmp -lm -o %:h/%:t:r.exe && ./%:r.exe<CR>

autocmd filetype java nnoremap <C-c> :w <bar> !javac % && java -enableassertions %:p <CR>
autocmd filetype python nnoremap <C-c> :w <bar> !python3 % <CR>
autocmd filetype haskell nnoremap <C-c> :w <bar> !ghci % <CR>
autocmd filetype perl nnoremap <C-c> :w <bar> !perl % <CR>
autocmd filetype go nnoremap <C-c> :w <bar> !go build % && ./%:p <CR>




autocmd filetype cpp vnoremap <C-l> :s/\%V\(_.*\)\%V/\/\* \1 \*\// <CR>
autocmd filetype xml vnoremap <C-l> :s/\%V\(.*\)\%V/<!-- \1 -->/  <CR>


"let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'

command YNext call YMusicNext()

:command Q q
:command W w


" Instructions:
" :GoImports - vim-go - autoImports and deletes imports
" gS - splitJoin - split struct declaration
" gJ - splitJoin - join struct declaratin
" :UltiSnipsEdit - ultisnips - open file with snippet scripts
" gd - vim-go - go to declaration
" ctrl+t - vim-go - go back from declaration
" :noh - vim - disable highlight for cirrent search
" :GoDefStack - vim-go - show stack of locations for gd
" :GoDefStackClear - vim-go - clear stack for gd
" :GoDecls - vim-go - see all the declaration in file
" :GoDeclsDir - vim-go - see all declarations in directory
" K - vim-go - see documentation and signature
" :GoChannelPeers - vim-go - shows channel recievers and senders
" :GoCallees - vim-go - get all possible implememtation of given anon function
" :GoCallers - vim-go - get all possible callers of given function
" :GoImpl + interface_name - vim-go - create implementation of interface
" :GoPlay - vim-go - open in go playground
" :%retab - vim - Change tabs
" https://vim.fandom.com/wiki/Using_marks
" snippets in go.snippets
" install gotags https://github.com/jstemmer/gotags
