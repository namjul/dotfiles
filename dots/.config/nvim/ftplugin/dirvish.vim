
" Overwrite default mapping for the benefit of my muscle memory. ('o' would normally open in a split window, but we want it to open in the current one.)
nnoremap <nowait><buffer><silent> o :<C-U>.call dirvish#open('edit', 0)<CR>
" close buffers using `gq`
nmap <buffer> q gq
