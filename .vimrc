" Make Vim more useful
set nocompatible

" Set syntax highlighting options.
set t_Co=256
syntax enable
set background=dark
colorscheme solarized


" Change mapleader
let mapleader="," 

filetype plugin indent on " load file type plugins + indentation
call pathogen#infect()

" Some wild settings
set encoding=utf-8 nobomb " BOM often causes trouble
set number "Show lines numbers
set ruler "Display current cursor position in lower right corner.
set laststatus=2 "Always show the status line
set showmatch " Show matching of: () [] {}
set mousehide "Hide mouse when typing
set mouse=a "Enable Mouse clicking
set noerrorbells " Disable error bells
set showmode " Show the current mode
set title " Show the filename in the window titlebar
set showcmd " Show the (partial) command as it’s being typed
set autoread " Auto read when file is changed
set hidden " Hide buffers, rather than close them
set autowrite "Write the old file out when switching between files.
set cursorline " Highlight current line
set wildmenu " More useful command-line completion
set wildmode=list:longest,full "Auto-completion menu
set gdefault " Add the g flag to search/replace by default
set nostartofline " Don’t reset cursor to start of line when moving around.
set shortmess=atI " Don’t show the intro message when starting Vim
set visualbell " Use visual bell instead of audible bell
set foldcolumn=3 " Column to show folds

"" Formatting
set autoindent " Indent at the same level as previous line
set smartindent

"" Whitespace
set nowrap " don't wrap lines
set tabstop=2 " Make tabs as wide as two spaces
set shiftwidth=2 " The # of spaces for indenting.
set expandtab " use spaces, not tabs (optional)
set backspace=indent,eol,start " backspace through everything in insert mode

"" Searching
set hlsearch " highlight matches
set incsearch " incremental searching
set ignorecase " searches are case insensitive...

"" Clear search highlights
noremap <silent><Leader>/ :nohls<CR>

" Select all
map <Leader>a ggVG

"" toggle wrap
nmap <silent> <leader>ww :set invwrap<CR>:set wrap?<CR>

"" No needs for backups, I have Git for that
"set noswapfile 
"set nobackup

" Local dirs
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
set undodir=~/.vim/undo

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

"" NerdTree
let NERDTreeChDirMode = 1
let NERDTreeWinSize=20
let NERDTreeShowHidden=1
:noremap ,n :NERDTreeToggle<cr>

" Paste toggle (,p)
set pastetoggle=<leader>p
map <leader>p :set invpaste paste?<CR>

"" zencoding new key map
"let g:user_zen_expandabbr_key = '<c-e>'

"" ctrlp settings
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

"" turn on spell checking
map <F8>  :setlocal spell spelllang=de <return>

" Remap :W to :w
command W w

" Fix page up and down
map <PageUp> <C-U>
map <PageDown> <C-D>
imap <PageUp> <C-O><C-U>
imap <PageDown> <C-O><C-D>

