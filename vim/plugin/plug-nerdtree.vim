
if !helper#IsPlugged('nerdtree') | finish | endif

let NERDTreeShowHidden=1
noremap <leader>n :NERDTreeToggle<CR>
