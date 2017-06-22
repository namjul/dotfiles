
if !helper#IsPlugged('neoterm') | finish | endif

let g:neoterm_split_on_tnew = 0
let g:neoterm_autoinsert = 1
let g:neoterm_position = 'vertical'

" exit Terminal mode by Esc
tnoremap <Esc> <C-\><C-n>
