" required vim with python3 support
call plug#begin('~/.vim/plugged')
" colorschemas
Plug 'morhetz/gruvbox'
Plug 'fatih/molokai'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

call plug#end()


let $PATH='$HOME/.cargo/bin:/usr/bin:/usr/local/bin:/bin:/usr/sbin:/sbin'
colorscheme gruvbox

set background=dark
set encoding=utf-8
" symbol to start special commands
let g:mapleader=','
set noswapfile

" for fuzzy file search
set path+=**
set wildmenu

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

" netrw | help netrw-browse-maps
let g:netrw_banner = 0 " disable banner
let g:netrw_liststyle = 3 " tree view of folders
let g:netrw_browse_split = 3 " open file in a new tab
let g:netrw_winsize = 10 " size of split


" set clipboard=unnamedplus

autocmd filetype cpp nnoremap <C-c> :w <bar> !clear && g++ -std=gnu++14 -O0 % -o %:h/%:t:r.lol && ./%:r.lol<CR>
" mb add :p before :h/%:t...

autocmd filetype c nnoremap <C-c> :w <bar> !clear && gcc -pthread -lm % -o %:p:h/%:t:r.lol && ./%:r.lol<CR>
autocmd filetype c nnoremap <C-k> :w <bar> !clear && gcc -c  % && gcc %:h/%:t:r.o -lglpk -lgmp -lm -o %:h/%:t:r.lol && ./%:r.lol<CR>

autocmd filetype java nnoremap <C-c> :w <bar> !javac % && java -enableassertions %:p <CR>
autocmd filetype python nnoremap <C-c> :w <bar> !python3 % <CR>
autocmd filetype haskell nnoremap <C-c> :w <bar> !ghci % <CR>
autocmd filetype perl nnoremap <C-c> :w <bar> !perl % <CR>
autocmd filetype go nnoremap <C-c> :w <bar> !go build % && ./%:p <CR>


" Commenting blocks of code.
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


autocmd filetype cpp vnoremap <C-l> :s/\%V\(_.*\)\%V/\/\* \1 \*\// <CR>
autocmd filetype xml vnoremap <C-l> :s/\%V\(.*\)\%V/<!-- \1 -->/  <CR>


:command Q q
:command W w

" Snippets:
" json-go
nnoremap <leader>jsg :-1read $HOME/.vim/snippets/json-go<CR>f"a
nnoremap <leader>erng :-1read $HOME/.vim/snippets/noerror-go<CR>j$a

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

" Instructions:
" gR - vim - vreplace
" :%retab - vim - Change tabs
" ,cc - vim - comment line
" ,cu - vim - uncomment line
" <C-c> - vim - compile
" :find *cp - vim - find files in a project ending in cp
" :b uniq - vim - open recent file with unique symbols providen
" ^] - vim+ctags - go to declaration
" g^] - vim+ctags - find each instance of variable
" ^t - vim+ctags - jump back
" ^x^n - vim - find in current file
" ^x^f - vim - find files (with wildcards)
" ^x^] - vim - find in tags
" ^n - vim - find anything
" :Sex - vim - explore dir with horizontal split
" :Vex - vim - explore dir with vertical split
"
" gS - splitJoin - split struct declaration
" gJ - splitJoin - join struct declaratin
" :GoImports - vim-go - autoImports and deletes imports
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
" https://vim.fandom.com/wiki/Using_marks
" snippets in go.snippets
" install gotags https://github.com/jstemmer/gotags
"
" cmd + / - iterm - find cursor position
