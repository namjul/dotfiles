"
"   ██╗   ██╗ ██╗ ███╗   ███╗ ██████╗   ██████╗
"   ██║   ██║ ██║ ████╗ ████║ ██╔══██╗ ██╔════╝
"   ██║   ██║ ██║ ██╔████╔██║ ██████╔╝ ██║
"   ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ██╔══██╗ ██║
" ██╗╚████╔╝  ██║ ██║ ╚═╝ ██║ ██║  ██║ ╚██████╗
" ╚═╝ ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ╚═╝  ╚═╝  ╚═════╝
"

set number "Show relative lines numbers
set showmatch " Show matching of: () [] {}
set mousehide "Hide mouse when typing
set mouse=a "Enable Mouse clicking
set showmode " Show the current mode
set cursorline " Highlight current line
set nostartofline " Don’t reset cursor to start of line when moving around.
set shortmess=atI " Don’t show the intro message when starting Vim
set visualbell " Use visual bell instead of audible bell
set backupcopy=yes "optimize webpack watch option
set clipboard+=unnamedplus
set ignorecase
set smartcase
set wildignorecase
set hidden

" Whitespace
set nowrap " don't wrap lines
set tabstop=2 " Make tabs as wide as two spaces
set shiftwidth=2 " The # of spaces for indenting.
set expandtab " use spaces, not tabs (optional)

set conceallevel=2

" Enable term 24 bit colour
set termguicolors

" Add the g flag to search/replace by default
set gdefault

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM MAPPINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""

" NORMAL
""""""""

" Avoid unintentional switches to Ex mode.
nnoremap Q <nop>

" Multi-mode mappings (Normal, Visual, Operating-pending modes).
noremap Y y$

" Move between windows.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Store relative line number jumps in the jumplist if they exceed a threshold.
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : '') . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : '') . 'j'

" Repurpose cursor keys (accessible near homerow via "SpaceFN" layout) for one
" of my most oft-use key sequences.
nnoremap <silent> <Up> :cprevious<CR>
nnoremap <silent> <Down> :cnext<CR>
nnoremap <silent> <Left> :cpfile<CR>
nnoremap <silent> <Right> :cnfile<CR>

nnoremap <silent> <S-Up> :lprevious<CR>
nnoremap <silent> <S-Down> :lnext<CR>
nnoremap <silent> <S-Left> :lpfile<CR>
nnoremap <silent> <S-Right> :lnfile<CR>

" VISUAL
""""""""

" Move between windows.
xnoremap <C-h> <C-w>h
xnoremap <C-j> <C-w>j
xnoremap <C-k> <C-w>k
xnoremap <C-l> <C-w>l

" COMMAND
"""""""""

cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" INSERT
""""""""

" esc mapping
imap jk <Esc>
imap <C-K> <Esc>
inoremap <C-c> <esc>

" TERMINAL
""""""""

" exit mapping
tnoremap <expr> <Esc> (&filetype == "fzf") ? "<Esc>" : "<c-\><c-n>"

" LEADER
""""""""

" set <leader>
let mapleader="\<Space>"

" <Leader><Leader> -- Open last buffer.
nnoremap <Leader><Leader> <C-^>

" close all windows but the active one
nnoremap <Leader>o :only<CR>

" <Leader>p -- Show the path of the current file (mnemonic: path; useful when
" you have a lot of splits and the status line gets truncated).
nnoremap <Leader>p :echo expand('%')<CR>

" Select all
nnoremap <Leader>a ggVG

" auto reload of vimrc
noremap <Leader>r :source ~/.vimrc<CR>

" quick save
nnoremap <Leader>w :write<CR>
nnoremap <Leader>x :exit<CR>
nnoremap <Leader>q :quit<CR>

" fzf mappings
nnoremap <silent><Leader>* :Rg <C-R><C-W><CR>
nnoremap <Leader>/ :Rg<space>
nnoremap <silent><Leader>f :Files<CR>
nnoremap <silent><Leader>b :Buffers<CR>
nnoremap <silent><Leader>h :History<CR>
nnoremap <silent><Leader>c :Commands<CR>

" Open new splits in a semantic way
nnoremap <Leader><C-h> :lefta vs new<CR>
nnoremap <Leader><C-j> :below sp new<CR>
nnoremap <Leader><C-k> :above sp new<CR>
nnoremap <Leader><C-l> :rightb vsp new<CR>

" Execute current file
nnoremap <Leader>2 :w<CR>:! ./%<CR>
