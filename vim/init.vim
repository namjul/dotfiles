" init.vim
" Neovim init (in place of vimrc)

if $TERM =~ '^\(rxvt\|screen\)\(\|-.*\)'
  set notermguicolors
elseif $TERM =~ '^\(xterm\|tmux\)\(\|-.*\)'
  set termguicolors
endif

let g:nvim_dir = fnamemodify(resolve(expand('$MYVIMRC')), ':p:h')

execute 'source ' . g:nvim_dir . '/vimrc'
