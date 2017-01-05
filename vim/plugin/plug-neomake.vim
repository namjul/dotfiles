
if !helper#IsPlugged('neomake') | finish | endif

" let g:neomake_open_list = 2
" let g:neomake_verbose = 3
let g:neomake_javascript_enabled_makers = ['eslint', 'flow']
let g:neomake_jsx_enabled_makers = ['eslint', 'flow']
autocmd! BufWritePost * Neomake
