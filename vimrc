
"""""""""""""""""""""
"
" PACKAGE MANAGEMENT
"
"""""""""""""""""""""

" start vundler
set nocompatible

call plug#begin('~/.vim/plugged')

" core plugins
Plug 'tpope/vim-sensible'

" main plugins
Plug 'tpope/vim-surround'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'editorconfig/editorconfig-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'myusuf3/numbers.vim'
Plug 'bkad/CamelCaseMotion'
Plug 'benekastah/neomake'
Plug 'tpope/vim-repeat'
Plug 'schickling/vim-bufonly'

" git
Plug 'tpope/vim-fugitive'
Plug 'Xuyuanp/nerdtree-git-plugin'

" autocomplete
Plug 'ternjs/tern_for_vim'

" togglable panels
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" language plugins
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'
Plug 'mxw/vim-jsx'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-markdown'

" snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

call plug#end()

"""""""""""""""""""""
"
" SETTINGS & KEYBINDINGS
"
"""""""""""""""""""""

" Some wild settings
set number "Show relative lines numbers
set showmatch " Show matching of: () [] {}
set mousehide "Hide mouse when typing
set mouse=a "Enable Mouse clicking
set showmode " Show the current mode
set hidden " Hide buffers, rather than close them
set cursorline " Highlight current line
set gdefault " Add the g flag to search/replace by default
set nostartofline " Don’t reset cursor to start of line when moving around.
set shortmess=atI " Don’t show the intro message when starting Vim
set visualbell " Use visual bell instead of audible bell
set clipboard+=unnamedplus

" Whitespace
set nowrap " don't wrap lines
set tabstop=2 " Make tabs as wide as two spaces
set shiftwidth=2 " The # of spaces for indenting.
set expandtab " use spaces, not tabs (optional)

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

" Set colorscheme.
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
let g:ctrlp_cmd = 'CtrlP .'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = 'node_modules\|bower_components\|DS_Store\|git'
let g:ctrlp_by_filename = 0 "search by filename as default
let g:ctrlp_regexp = 1 "regex search as default

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

" tern disable preview window
set completeopt-=preview

" ultisnips
let g:UltiSnipsUsePythonVersion = 2
let g:UltiSnipsExpandTrigger='<c-j>'
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

let g:markdown_fenced_languages = ['html', 'javascript', 'json', 'bash=sh']
