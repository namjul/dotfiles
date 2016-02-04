
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
Plugin 'vim-airline/vim-airline-themes'
Plugin 'editorconfig/editorconfig-vim'
" Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdcommenter'
Plugin 'jiangmiao/auto-pairs'
Plugin 'myusuf3/numbers.vim'
Plugin 'bkad/CamelCaseMotion'
Plugin 'benekastah/neomake'
Plugin 'tpope/vim-repeat'

" git
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'Xuyuanp/nerdtree-git-plugin'

" autocomplete
Plugin 'Valloric/YouCompleteMe'

" togglable panels
Plugin 'scrooloose/nerdtree'

" language plugins
Plugin 'pangloss/vim-javascript'
Plugin 'elzr/vim-json'
Plugin 'mxw/vim-jsx'
Plugin 'mattn/emmet-vim'

" snippets
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'

call vundle#end()
filetype plugin indent on


"""""""""""""""""""""
"
" SETTINGS & KEYBINDINGS
"
"""""""""""""""""""""

" Some wild settings
set encoding=utf-8
set number "Show relative lines numbers
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

set clipboard+=unnamedplus

" Formatting
set autoindent " Indent at the same level as previous line
set smartindent

" Whitespace
set nowrap " don't wrap lines
set tabstop=2 " Make tabs as wide as two spaces
set shiftwidth=2 " The # of spaces for indenting.
set expandtab " use spaces, not tabs (optional)
set backspace=indent,eol,start " backspace through everything in insert mode

" Searching
set hlsearch " highlight matches
set incsearch " incremental searching
set ignorecase " searches are case insensitive...

" set <leader>
let mapleader=","

" Clear search highlights
noremap <silent><Leader>/ :nohls<CR>

" Select all
map <Leader>a ggVG

" mousesupport if not using neovim
if !has('nvim')
	set ttymouse=xterm2
endif

" Set syntax highlighting options.
syntax enable
set background=dark
colorscheme solarized

" Local dirs
set backupdir=~/.vim/backups//
set directory=~/.vim/swaps//
set undodir=~/.vim/undo//

" open vimrc
nnoremap <leader>v :e  ~/.vimrc<CR>
nnoremap <leader>V :tabnew  ~/.vimrc<CR>

" toogle background
map <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Maximize window and return to previous split structure
nmap t% :tabedit %<CR>
nmap td :tabclose<CR>

" To open a new empty buffer (http://joshldavis.com/2014/04/05/vim-tab-madness-buffers-vs-tabs/)
" This replaces :tabnew which I used to bind to this mapping
nmap <leader>T :enew<cr>
" Move to the next buffer
nmap <leader>l :bnext<CR>
" Move to the previous buffer
nmap <leader>h :bprevious<CR>
" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>
" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

"""""""""""""""""""""
"
" PLUGINS
"
"""""""""""""""""""""

" camelCaseMotion settings
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge

" ctrlp settings
let g:ctrlp_map = '<c-p>'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

" NerdTree settings
let NERDTreeShowHidden=1
noremap <leader>n :NERDTreeToggle<CR>

" jsx for .js files
let g:jsx_ext_required = 0

" airline statusbar settings
if !exists("g:airline_symbols")
  let g:airline_symbols = {}
endif
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1 " Enable the list of buffers
let g:airline#extensions#tabline#fnamemod = ':t' " Show just the filename

" neomake settings
autocmd! BufWritePost * Neomake
" let g:neomake_open_list = 2

" emmit settings
let g:user_emmet_leader_key='<C-Z>'
