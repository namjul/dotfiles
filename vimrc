
"""""""""""""""""""""
"
" PACKAGE MANAGEMENT
"
"""""""""""""""""""""

" start vundler
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" core plugins
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'

" main plugins
Plugin 'tpope/vim-surround'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'scrooloose/syntastic'

" autocomplete
"Plugin 'Valloric/YouCompleteMe'

" togglable panels
Plugin 'scrooloose/nerdtree'

" language plugins
Plugin 'pangloss/vim-javascript'

call vundle#end()
filetype plugin indent on


"""""""""""""""""""""
"
" SETTINGS & KEYBINDINGS
"
"""""""""""""""""""""

" Some wild settings
set encoding=utf-8
set relativenumber "Show relative lines numbers
set ruler "Display current cursor position in lower right corner.
set showmatch " Show matching of: () [] {}
set mousehide "Hide mouse when typing
set mouse=a "Enable Mouse clicking
set showmode " Show the current mode
set hidden " Hide buffers, rather than close them
set cursorline " Highlight current line
set wildmenu " More useful command-line completion
set gdefault " Add the g flag to search/replace by default
set nostartofline " Don’t reset cursor to start of line when moving around.
set shortmess=atI " Don’t show the intro message when starting Vim
set visualbell " Use visual bell instead of audible bell
"set noerrorbells " Disable error bells
set autoread " Auto read when file is changed
"set autowrite "Write the old file out when switching between files.

" Formatting
set autoindent " Indent at the same level as previous line
set smartindent

" Whitespace
set nowrap " don't wrap lines
set tabstop=2 " Make tabs as wide as two spaces
set shiftwidth=2 " The # of spaces for indenting.
set expandtab " use spaces, not tabs (optional)
"set backspace=indent,eol,start " backspace through everything in insert mode

" Searching
set hlsearch " highlight matches
set incsearch " incremental searching
set ignorecase " searches are case insensitive...

" Clear search highlights
noremap <silent><Leader>/ :noh<CR>

" Select all
map <Leader>a ggVG

" set <leader>
let mapleader=","

" mousesupport if not using neovim
if !has('nvim')
	set ttymouse=xterm2
endif

" Set syntax highlighting options.
syntax enable
set background=dark
colorscheme solarized

" open vimrc
nnoremap <leader>v :e  ~/.vimrc<CR>
nnoremap <leader>V :tabnew  ~/.vimrc<CR>

" toogle background
map <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" ctrlp settings
let g:ctrlp_map = '<c-p>'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

" NerdTree settings
let NERDTreeShowHidden=1
noremap <leader>n :NERDTreeToggle<CR>

" airline statusbar settings
if !exists("g:airline_symbols")
  let g:airline_symbols = {}
endif
let g:airline_powerline_fonts = 1
