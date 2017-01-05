
if !helper#IsPlugged('neomake') | finish | endif

" neomake settings
" let g:neomake_open_list = 2
" let g:neomake_verbose = 3
autocmd! BufWritePost * Neomake
