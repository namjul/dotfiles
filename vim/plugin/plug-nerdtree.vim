
if !helper#IsPlugged('nerdtree') | finish | endif

let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
noremap <leader>n :NERDTreeToggle<CR>
noremap <leader>f :NERDTreeFind<CR>
