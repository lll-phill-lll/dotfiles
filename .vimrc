call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'cquery-project/cquery', {'for': ['c', 'c++']}
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go'}
Plug 'fatih/motion', {'for': 'go'}
Plug 'AndrewRadev/splitjoin.vim'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'majutsushi/tagbar'

Plug 'mileszs/ack.vim'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'chase/vim-ansible-yaml'

Plug 'artur-shaik/vim-javacomplete2', {'for': 'java'}

Plug 'ctrlpvim/ctrlp.vim'

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
inoremap [ []<esc>i
inoremap ( ()<esc>i
inoremap { {}<esc>i
inoremap " ""<esc>i
inoremap ' ''<esc>i

" Snippets:
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

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

" vim-go:
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>run  <Plug>(go-run)
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
autocmd FileType go nmap <Leader>i <Plug>(go-imports)
autocmd FileType go nmap <Leader>ds <Plug>(go-def-split)
autocmd FileType go nmap <Leader>dv <Plug>(go-def-vertical)
autocmd FileType go nmap <Leader>dt <Plug>(go-def-tab)
autocmd FileType go nmap <Leader>ref <Plug>(go-referrers)

let g:go_decls_includes = "func,type"

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1

let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

" ctrlp:
set runtimepath^=~/.vim/plugged/ctrlp.vim
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_show_hidden = 1

" mappings

map <C-n> :NERDTreeToggle<CR>
map <Leader> <Plug>(easymotion-prefix)

" Go related mappings
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>r <Plug>(go-run)
au FileType go nmap <Leader>b <Plug>(go-build)
au FileType go nmap <Leader>t <Plug>(go-test)
au FileType go nmap gd <Plug>(go-def-tab)
" Run goimports along gofmt on each save
let g:go_fmt_command = "goimports"
" Automatically get signature/type info for object under cursor
let g:go_auto_type_info = 1

" from https://gist.github.com/tyru/984296
" Substitute a:from => a:to by string.
" To substitute by pattern, use substitute() instead.
function! s:substring(str, from, to)
  if a:str ==# '' || a:from ==# ''
      return a:str
  endif
  let str = a:str
  let idx = stridx(str, a:from)
  while idx !=# -1
      let left  = idx ==# 0 ? '' : str[: idx - 1]
      let right = str[idx + strlen(a:from) :]
      let str = left . a:to . right
      let idx = stridx(str, a:from)
  endwhile
  return str
endfunction

function! s:chomp(string)
  return substitute(a:string, '\n\+$', '', '')
endfunction

function! s:go_guru_scope_from_git_root()
" chomp because get rev-parse returns line with newline at the end
  return s:chomp(s:substring(system("git rev-parse --show-toplevel"),$GOPATH . "/src/","")) . "/..."
endfunction

au FileType go silent exe "GoGuruScope " . s:go_guru_scope_from_git_root()

" use ag vim
let g:ackprg = 'ag --nogroup --nocolor --column'

let g:deoplete#enable_at_startup = 1
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }

" comments
autocmd filetype cpp vnoremap <C-l> :s/\%V\(_.*\)\%V/\/\* \1 \*\// <CR>
autocmd filetype xml vnoremap <C-l> :s/\%V\(.*\)\%V/<!-- \1 -->/  <CR>


function! s:ag_to_qf(line)
  let parts = split(a:line, ':')
  return {'filename': parts[0], 'lnum': parts[1], 'col': parts[2],
        \ 'text': join(parts[3:], ':')}
endfunction

function! s:ag_handler(lines)
  if len(a:lines) < 2 | return | endif

  let cmd = get({'ctrl-x': 'split',
               \ 'ctrl-v': 'vertical split',
               \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')
  let list = map(a:lines[1:], 's:ag_to_qf(v:val)')

  let first = list[0]
  execute cmd escape(first.filename, ' %#\')
  execute first.lnum
  execute 'normal!' first.col.'|zz'

  if len(list) > 1
    call setqflist(list)
    copen
    wincmd p
  endif
endfunction

command! -nargs=* Ag call fzf#run({
\ 'source':  printf('ag --nogroup --column --color "%s"',
\                   escape(empty(<q-args>) ? '^(?=.)' : <q-args>, '"\')),
\ 'sink*':    function('<sid>ag_handler'),
\ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x --delimiter : --nth 4.. '.
\            '--multi --bind=ctrl-a:select-all,ctrl-d:deselect-all '.
\            '--color hl:68,hl+:110',
\ 'down':    '50%'
\ })
"let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'

function! MultiLineSubstitute() abort
  normal!gvy
  let expression = substitute(@0, "\<C-J>", '\\n', 'g')
  execute '%s,'.expression.','.input("Replacement: ")
endfunction

vnoremap <F1> :<C-U>call MultiLineSubstitute()<CR>

function OpenYMusic()
     :silent !osascript -e 'tell application "Firefox" to open location "http://music.yandex.ru"'
     :redraw!
endfunction

command YMusic call OpenYMusic()

function YMusicNext()
     :silent !osascript -e 'tell application "Firefox" \n repeat with w in (every window) \n repeat with t in (every tab whose URL contains "music.yandex.ru") of w \n tell t to do JavaScript "document.querySelector(".player-controls__btn_prev").click();"'
     :redraw!
endfunction

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
