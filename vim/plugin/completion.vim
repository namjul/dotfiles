
if !helper#IsPlugged('deoplete.nvim') | finish | endif

let g:deoplete#file#enable_buffer_path = 1
let g:deoplete#enable_at_startup = 1
let g:tern_request_timeout = 1
let g:tern_show_signature_in_pum = 0
set completeopt-=preview

" needed to work with ultisnips
call deoplete#custom#set('ultisnips', 'matchers', ['matcher_fuzzy'])
