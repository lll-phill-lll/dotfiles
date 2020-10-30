" Vim syntax file
" Language: Phill goals language
" Maintainer: Filitov Mikhail filitovme@gmail.com
" Latest Revision: 20 oct 2020

syntax clear
if exists("b:current_syntax")
  finish
endif

"----------------------------------------------------------------
" Syntax for goals filetype
"----------------------------------------------------------------

syntax match TableMiddle "=*"
highlight TableMiddle guifg=#6E0007 gui=bold

syntax match TableBorderHor "^+-.*"
highlight TableBorderHor guifg=#70CCE6 gui=bold

syntax match TableBorder "|"
highlight TableBorder guifg=#70CCE6 gui=bold

syntax match TableTitle "*\..*\.(|)@!*"
highlight TableTitle guifg=#B37A25 gui=bold

syntax match Done "\[Y\]"
highlight Done guifg=#9DCF91 gui=bold

syntax match NotDone "\[X\]"
highlight NotDone guifg=#A64444 gui=bold

syn match Num '\d'
hi def link Num    Type

syntax match MI "\[MI\]"
highlight MI guibg=#E3F1FA guifg=#000000 gui=bold

syntax match WR "\[WR\]"
highlight WR guibg=#FA9198 guifg=#000000 gui=bold

syntax match CR "\[CR\]"
highlight CR guibg=#B4DE97 guifg=#000000 gui=bold
