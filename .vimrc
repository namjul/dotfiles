set nocompatible " Make Vim more useful
filetype off " required!

" Use Vundle as plugin manager
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'majutsushi/tagbar'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/camelcasemotion'
Plugin 'marijnh/tern_for_vim'
Plugin 'Raimondi/delimitMate'
Plugin 'mattn/emmet-vim'
Plugin 'myusuf3/numbers.vim'
Plugin 'spf13/PIV'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'HTML-AutoCloseTag'
Plugin 'suan/vim-instant-markdown'


Plugin 'ap/vim-css-color'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'groenewege/vim-less'
Plugin 'wavded/vim-stylus'
Plugin 'pangloss/vim-javascript'
Plugin 'digitaltoad/vim-jade'
Plugin 'tpope/vim-markdown'
Plugin 'mxw/vim-jsx'

Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" make css autocomplete working
autocmd FileType less,stylus,scss setlocal omnifunc=csscomplete#CompleteCSS

" Set syntax highlighting options.
set t_Co=256
syntax enable
set background=dark
colorscheme solarized
let g:syntastic_javascript_checkers = ['jsxhint']

" Change mapleader
let mapleader="," 


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
set nofoldenable " disable folding"

"" Formatting
set autoindent " Indent at the same level as previous line
set smartindent
set cindent 

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

" Local dirs
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
set undodir=~/.vim/undo

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Disable beep and flash with an autocmd
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

"" NerdTree
let NERDTreeChDirMode = 1
let NERDTreeWinSize=20
let NERDTreeShowHidden=1
:noremap ,n :NERDTreeToggle<cr>

" Paste toggle (,p)
set pastetoggle=<leader>p
map <leader>p :set invpaste paste?<CR>

"copy/paste mapping
vnoremap <C-c> "+y
inoremap <C-v> <C-o>"+p

" ctrlp settings
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" turn on spell checking
map <F8>  :setlocal spell spelllang=de <return>

" ctag mapping
nmap <F9> :TagbarToggle<CR>

" Remap :W to :w
command W w

" Remap Esc to jk and kj
":imap jk <Esc>
":imap kj <Esc>

" Fix page up and down
map <PageUp> <C-U>
map <PageDown> <C-D>
imap <PageUp> <C-O><C-U>
imap <PageDown> <C-O><C-D>

" airline statusbar settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
"let g:airline_left_sep = '▙'
"let g:airline_right_sep = '▟'

" CamelcaseMotion
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
sunmap w
sunmap b
sunmap e

" closetag
let g:closetag_html_style=1 

" emmet
let g:user_emmet_leader_key='<C-Z>'

" instant markdown
let g:instant_markdown_slow = 1
let g:instant_markdown_autostart = 0

" snippets mapping
imap <C-J> <esc>a<Plug>snipMateNextOrTrigger
smap <C-J> <Plug>snipMateNextOrTrigger

"YouCompleteME
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_add_preview_to_completeopt=0
let g:ycm_confirm_extra_conf=0
set completeopt-=preview

" toogle background
map <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>

" Maximize window and return to previous split structure
nmap t% :tabedit %<CR>
nmap td :tabclose<CR>
