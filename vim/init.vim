" init.vim
" Neovim init (in place of vimrc)

set termguicolors

let g:nvim_dir = fnamemodify(resolve(expand('$MYVIMRC')), ':p:h')

execute 'source ' . g:nvim_dir . '/vimrc'
