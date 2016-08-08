
"""""""""""""""""""""
"
" PACKAGE MANAGEMENT
"
"""""""""""""""""""""

" start vundler
set nocompatible

call plug#begin('~/.vim/bundle')

" core plugins
Plug 'tpope/vim-sensible'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Shougo/deoplete.nvim'

" main plugins
Plug 'mklabs/split-term.vim'
Plug 'tpope/vim-surround'
Plug 'editorconfig/editorconfig-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'myusuf3/numbers.vim'
Plug 'bkad/CamelCaseMotion'
Plug 'benekastah/neomake'
Plug 'tpope/vim-repeat'
Plug 'schickling/vim-bufonly'
Plug 'itchyny/lightline.vim'
Plug 'critiqjo/vim-bufferline'

" git
Plug 'tpope/vim-fugitive'
Plug 'Xuyuanp/nerdtree-git-plugin'

" autocomplete
Plug 'ternjs/tern_for_vim', { 'do': 'npm install', 'for': 'javascript' }
Plug 'carlitux/deoplete-ternjs'

" togglable panels
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" language plugins
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'javascript' }
Plug 'elzr/vim-json'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-markdown'
Plug 'moll/vim-node'
Plug 'digitaltoad/vim-pug'
Plug 'flowtype/vim-flow', { 'for': 'javascript' }

" snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" theme
Plug 'chriskempson/base16-vim'

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
set backupcopy=yes "optimize webpack watch option
set clipboard+=unnamedplus
set ignorecase

" Whitespace
set nowrap " don't wrap lines
set tabstop=2 " Make tabs as wide as two spaces
set shiftwidth=2 " The # of spaces for indenting.
set expandtab " use spaces, not tabs (optional)

" esc mapping
:inoremap jk <esc>

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
set termguicolors
set background=dark
colorscheme base16-solarized-dark

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

" support ejs 
au BufNewFile,BufRead *.ejs set filetype=html

" auto reload of vimrc
noremap <leader>r :source $MYVIMRC<CR>

" quick save
noremap <leader>s :update<CR>

" format JSON
" map <leader>j !python -m json.tool<CR>
command J :%!python -mjson.tool

"""""""""""""""""""""
"
" PLUGINS
"
"""""""""""""""""""""

" bufferline
let g:bufferline_active_buffer_left = ''
let g:bufferline_active_buffer_right = ''
let g:bufferline_show_bufnr = 0
let g:bufferline_fname_mod = ':t'
let g:bufferline_pathshorten = 1

" lightline
set noshowmode
set showtabline=2
let g:lightline = {
      \ 'mode_map': {
      \   'n': 'N',
      \   'i': 'I',
      \   'v': 'V'
      \ },
      \ 'tabline': {
      \   'left': [ ['tabs'], ['bufferline'] ],
      \   'right': []
      \ },
      \ 'tab': {
	    \   'active': [ 'tabnum' ],
	    \   'inactive': [ 'tabnum' ]
      \ },
      \ 'component_expand': {
      \   'bufferline': 'LightlineBufferline',
      \ },
      \ 'component_type': {
      \   'bufferline': 'tabsel',
      \ },
      \ 'colorscheme': 'solarized_dark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'readonly' ], [ 'filename' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightLineFugitive',
      \   'readonly': 'LightLineReadonly',
      \   'filename': 'LightLineFilename',
      \   'modified': 'LightLineModified',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

function! LightLineModified()
  if &filetype == "help"
    return ""
  elseif &modified
    return "+"
  elseif &modifiable
    return ""
  else
    return ""
  endif
endfunction

function! LightLineReadonly()
  if &filetype == "help"
    return ""
  elseif &readonly
    return "RO"
  else
    return ""
  endif
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
       \ ('' != expand('%:t') ? expand('%:t') : '[No Name]') .
       \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? '┣ '._ : ''
  endif
  return ''
endfunction

function! LightlineBufferline()
  call bufferline#refresh_status()
  return [ g:bufferline_status_info.before, g:bufferline_status_info.current, g:bufferline_status_info.after]
endfunction

" ctrlp settings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP .'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = 'node_modules\|bower_components\|DS_Store\|git'
let g:ctrlp_by_filename = 0 "search by filename as default
let g:ctrlp_regexp = 1 "regex search as default

" Use deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#file#enable_buffer_path = 1
" use tab to forward cycle
inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" use tab to backward cycle
inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

" camelCaseMotion settings
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge

" NerdTree settings
let NERDTreeShowHidden=1
noremap <leader>n :NERDTreeToggle<CR>

" jsx for .js files
let g:jsx_ext_required = 0

" neomake settings
autocmd! BufWritePost * Neomake
" let g:neomake_open_list = 2
" let g:neomake_verbose = 3

" vim-flow
let g:flow#autoclose = 1

" emmit settings
let g:user_emmet_leader_key='<C-Z>'

" ultisnips
let g:UltiSnipsUsePythonVersion = 2
let g:UltiSnipsExpandTrigger='<c-j>'
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

let g:markdown_fenced_languages = ['html', 'javascript', 'json', 'bash=sh']

" nerdcommenter
let g:NERDSpaceDelims = 1
