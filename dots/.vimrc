"
"   ██╗   ██╗ ██╗ ███╗   ███╗ ██████╗   ██████╗
"   ██║   ██║ ██║ ████╗ ████║ ██╔══██╗ ██╔════╝
"   ██║   ██║ ██║ ██╔████╔██║ ██████╔╝ ██║
"   ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ██╔══██╗ ██║
" ██╗╚████╔╝  ██║ ██║ ╚═╝ ██║ ██║  ██║ ╚██████╗
" ╚═╝ ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ╚═╝  ╚═╝  ╚═════╝
"

let g:plugin_path = '~/.config/nvim/plugged'

call plug#begin(g:plugin_path)

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""

" sensible defaults
Plug 'tpope/vim-sensible'
" enables the repeat command to work with external plugins
Plug 'tpope/vim-repeat'
" git integration
Plug 'tpope/vim-fugitive'
" git branch viewer
Plug 'rbong/vim-flog'
" open files on github
Plug 'tpope/vim-rhubarb'
" adds operators for surrounding characters
Plug 'tpope/vim-surround'
" set of complementary pair commands
Plug 'tpope/vim-unimpaired'
" Temporarily commenting
Plug 'tpope/vim-commentary'
" seperate `cut` form `delete`
Plug 'svermeulen/vim-cutlass'
" adds a subsitute operator
Plug 'svermeulen/vim-subversive'
" adds easy access to history of yanks
Plug 'svermeulen/vim-yoink'
" enhancements to vim's search commands
Plug 'wincent/loupe'
" helper for search and replace
Plug 'wincent/scalpel'
" better statusbar
Plug 'itchyny/lightline.vim'
" support editor config files (https://editorconfig.org/)
Plug 'editorconfig/editorconfig-vim'
" makes `FocusGained` and `FocusLost` work in terminal vim
" `autoread` options then works as expected
Plug 'tmux-plugins/vim-tmux-focus-events'
" fuzzy search
Plug '/home/linuxbrew/.linuxbrew/opt/fzf/'
Plug 'junegunn/fzf.vim'
" zen mode for writing
Plug 'junegunn/goyo.vim'
" makes space indented code visible
Plug 'Yggdroot/indentLine'
Plug 'lukas-reineke/indent-blankline.nvim'
" combines the fzf with the concept from notational
Plug 'alok/notational-fzf-vim'
" allows to send commands from vim to tmux
Plug 'benmills/vimux'
" simplifies running jest test from vim
Plug 'tyewang/vimux-jest-test'
" file explorer
Plug 'justinmk/vim-dirvish'
" improves the display of line numbers
Plug 'jeffkreeftmeijer/vim-numbertoggle'
" auto closes pairs
Plug 'jiangmiao/auto-pairs'
" highlights xml tags enclosing the cursor
Plug 'Valloric/MatchTagAlways'
" helper for resizing windows
Plug 'simeji/winresizer'
Plug 'camspiers/lens.vim'
" auto closes the xml tag
Plug 'alvan/vim-closetag'
" colorscheme
Plug 'morhetz/gruvbox'
" Plug 'chriskempson/base16-vim'
" Plug 'icymind/NeoSolarized'
" Plug 'arcticicestudio/nord-vim'
" Plug 'mhartington/oceanic-next'
" Plug 'srcery-colors/srcery-vim'
" Plug 'sonph/onehalf', { 'rtp': 'vim/' }
" Plug 'drewtempelmeyer/palenight.vim'
" Plug 'ayu-theme/ayu-vim'
" Plug 'rakr/vim-one'
" add info to sidebar about git
Plug 'airblade/vim-gitgutter'
" improves vim 'commit' buffer
Plug 'rhysd/committia.vim'
" general language support
Plug 'sheerun/vim-polyglot'
" improves dx in node.js env
Plug 'moll/vim-node'
" snippets engine
Plug 'SirVer/ultisnips'
" general snippets collection
Plug 'honza/vim-snippets'
" interact with github gist from vim
Plug 'mattn/gist-vim'
" needed for `gist-vim`
Plug 'mattn/webapi-vim'
" linter, fixer and lsp
Plug 'dense-analysis/ale'
" autocomplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" color name highlighter
Plug 'ap/vim-css-color'
" highlights yanked text
Plug 'machakann/vim-highlightedyank'
" enhance bullet points management
Plug 'dkarter/bullets.vim'
" highlight trailing whitespace
Plug 'csexton/trailertrash.vim'

call plug#end()

" Shortcut for checking if a plugin is loaded
function! s:has_plugin(plugin)
  let lookup = 'g:plugs["' . a:plugin . '"]'
  return exists(lookup)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL CONFIGURATIONS
"""""""""""""""""""""""""""""""""""""""""""""""""""""

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

" Centralize backups, swapfiles and undo history
set backupdir=~/.config/nvim/backups
" set directory=.,$TEMP " Stop the swp file warning

if has("persistent_undo")
  set undodir=~/.config/nvim/undo
  set undofile
  set undolevels=1000
  set undoreload=10000
endif

" default dark
set background=dark

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM FUNCTIONS
"""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LightlineFilename()
  let filename = expand('%:f') !=# '' ? expand('%:f') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction

function! LightlineReload()
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

function! s:onColorSchemeChange(scheme)
  let l:colour_scheme_map = {'NeoSolarized': 'solarized'}

  " Try a scheme provided already
  execute 'runtime autoload/lightline/colorscheme/'.a:scheme.'.vim'
  if exists('g:lightline#colorscheme#{a:scheme}#palette')
    let g:lightline.colorscheme = a:scheme
  else  " Try falling back to a known colour scheme
    let l:colors_name = get(l:colour_scheme_map, a:scheme, '')
    if empty(l:colors_name)
      return
    else
      let g:lightline.colorscheme = l:colors_name
    endif
  endif
  call LightlineReload()
endfunction

function! PlainText()
  if has('conceal')
    setlocal concealcursor=nc
  endif

  setlocal nolist
  setlocal linebreak
  setlocal textwidth=0
  setlocal wrap
  setlocal wrapmargin=0

  nnoremap <buffer> j gj
  nnoremap <buffer> k gk
  nnoremap <buffer> 0 g0
  nnoremap <buffer> ^ g^
  nnoremap <buffer> $ g$
  vnoremap <buffer> j gj
  vnoremap <buffer> k gk
  vnoremap <buffer> 0 g0
  vnoremap <buffer> ^ g^
  vnoremap <buffer> $ g$

  " Create undo 'snapshots' when being in inline editing.
  "
  " From:
  " - https://github.com/wincent/wincent/blob/44b112f26ec6435a9b78e64225eb0f9082999c1e/aspects/vim/files/.vim/autoload/wincent/functions.vim#L32
  " - https://twitter.com/vimgifs/status/913390282242232320
  "
  inoremap <buffer> ! !<C-g>u
  inoremap <buffer> , ,<C-g>u
  inoremap <buffer> . .<C-g>u
  inoremap <buffer> : :<C-g>u
  inoremap <buffer> ; ;<C-g>u
  inoremap <buffer> ? ?<C-g>u

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" AUTOCOMMANDS
"""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup lightline-events
  autocmd!
  autocmd ColorScheme * call s:onColorSchemeChange(expand("<amatch>"))
augroup END

augroup filetypedetect
  autocmd BufRead,BufNewFile tsconfig.json set filetype=json5
  autocmd BufRead,BufNewFile .eslintrc.json set filetype=json5
  autocmd FileType markdown call PlainText()
augroup END

augroup NamDirvish
  autocmd!
  " Overwrite default mapping for the benefit of my muscle memory.
  " ('o' would normally open in a split window, but we want it to open in the
  " current one.)
  autocmd FileType dirvish silent! nnoremap <nowait><buffer><silent> o :<C-U>.call dirvish#open('edit', 0)<CR>
  " close buffers using `gq` (dirvish)
  autocmd FileType dirvish nmap <buffer> q gq
  autocmd FileType dirvish nmap <buffer>cd :cd %:p:h<CR>:pwd<CR>
augroup END

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGIN SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""

if s:has_plugin('nord-vim')
  colorscheme nord
endif

if s:has_plugin('oceanic-next')
  colorscheme OceanicNext
  let g:oceanic_next_terminal_bold = 1
  let g:oceanic_next_terminal_italic = 1
endif

if s:has_plugin('srcery-vim')
  colorscheme srcery
  let g:srcery_italic = 1
endif

if s:has_plugin('onehalf')
  colorscheme onehalfdark
  highlight Comment cterm=italic gui=italic
endif

if s:has_plugin('ayu-vim')
  " let ayucolor="light"  " for light version of theme
  let ayucolor="mirage" " for mirage version of theme
  " let ayucolor="dark"   " for dark version of theme
  colorscheme ayu
endif

if s:has_plugin('vim-one')
  colorscheme one
  set background=dark
endif

if s:has_plugin('gruvbox')
  let g:gruvbox_contrast_dark = 'soft'
  let g:gruvbox_contrast_light = 'soft'
  let g:gruvbox_italic = 1
  set background=dark
  colorscheme gruvbox
endif

if s:has_plugin('ale')
  let g:ale_virtualtext_cursor = 1
  let g:ale_virtualtext_prefix = '❐ '
  let g:ale_echo_msg_format = '[%linter%] [%severity%] %code: %%s'
  let g:ale_lint_on_text_changed = 'never'
  let g:ale_linter_aliases = {
        \ 'javascriptreact': ['javascript', 'jsx'],
        \ 'typescriptreact': ['typescript', 'tsx'],
        \}
  let g:ale_linters = {
        \ 'typescript': ['eslint', 'tsserver', 'typecheck'],
        \ 'javascript': ['eslint', 'tsserver', 'flow'],
        \}
  let g:ale_fixers = {
        \ 'javascriptreact': ['prettier'],
        \ 'typescriptreact': ['prettier'],
        \ 'javascript': ['prettier'],
        \ 'typescript': ['prettier'],
        \ 'html': ['prettier'],
        \ 'json': ['prettier'],
        \ 'mdx': ['prettier']
        \ }
  let g:ale_javascript_prettier_use_local_config = 1

  let g:ale_sign_error="✖"
  let g:ale_sign_warning="⚠"
  let g:ale_sign_info="ℹ"

  let g:ale_fix_on_save = 1

  highlight link ALEVirtualTextError GruvboxRed
  highlight link ALEVirtualTextWarning GruvboxYellow
  highlight link ALEVirtualTextInfo GruvboxBlue

  nmap <silent> [g <Plug>(ale_previous_wrap)
  nmap <silent> ]g <Plug>(ale_next_wrap)
  nmap <silent> gD <Plug>(ale_go_to_type_definition)
  nmap <silent> gd <Plug>(ale_go_to_definition)
  nmap <silent> gr <Plug>(ale_find_references) :ALEFindReferences -relative<Return>
  nmap <silent><leader>rn <Plug>(ale_rename)

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      :ALEHover
    endif
  endfunction

  " Use K to show documentation in preview window.
  nmap <silent> K :call <SID>show_documentation()<CR>

endif

if s:has_plugin('deoplete.nvim')
  let g:deoplete#enable_at_startup = 1
endif

if s:has_plugin('fzf.vim')
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 1 } }
  let g:fzf_action = {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit',
        \}
endif

if s:has_plugin('lightline.vim')
  set noshowmode
  let g:lightline = {
        \ 'mode_map': {
        \   'n': 'N',
        \   'i': 'I',
        \   'v': 'V'
        \ },
        \ 'colorscheme': 'gruvbox',
        \ 'active': {
        \   'left': [ [ 'mode',  'paste' ],
        \             [ 'gitbranch', 'readonly' ], ['filename'] ],
        \   'right': [ [  'percent', 'lineinfo' ],
        \              [ 'fileencoding' ], ['filetype'] ]
        \ },
        \ 'component_function': {
        \   'gitbranch': 'FugitiveHead',
        \   'filename': 'LightlineFilename',
        \ },
        \ 'separator': { 'left': '', 'right': '' },
        \ 'subseparator': { 'left': '', 'right': '' }
        \ }

  command! LightlineReload call LightlineReload()

endif

if s:has_plugin('neoterm')
  let g:neoterm_autoinsert = 1
endif

if s:has_plugin('ultisnips')
  let g:UltiSnipsExpandTrigger='<c-j>'
  let g:UltiSnipsJumpForwardTrigger='<c-j>'
  let g:UltiSnipsJumpBackwardTrigger='<c-k>'
endif

if s:has_plugin('vim-fugitive')
  set diffopt+=vertical
  nmap <leader>gb :Gblame<cr>
  nmap <leader>gs :Gstatus<cr>
  nmap <leader>gc :Gcommit -v<cr>
  nmap <leader>ga :Git add -p<cr>
  nmap <leader>gm :Gcommit --amend<cr>
  nmap <leader>gp :Gpush<cr>
  nmap <leader>gd :Gdiff<cr>
  nmap <leader>gw :Gwrite<cr>
  nmap <leader>gbr :Gbrowse<cr>
endif

if s:has_plugin('vim-flog')
  nmap <leader>gf :Flog<cr>
endif

if s:has_plugin('vim-polyglot')
  let g:javascript_plugin_jsdoc = 1
  let g:javascript_plugin_flow = 1
  let g:vim_markdown_fenced_languages = ['jsx=javascriptreact', 'js=javascript', 'tsx=typescriptreact', 'ts=typescriptreact']
  let g:vim_markdown_no_extensions_in_markdown = 1
  let g:vim_markdown_auto_insert_bullets = 0
  let g:vim_markdown_new_list_item_indent = 0
endif

if s:has_plugin('vimux')
  " Prompt for a command to run
  map <Leader>vp :VimuxPromptCommand<CR>
  " Run last command executed by VimuxRunCommand
  map <Leader>vl :VimuxRunLastCommand<CR>
  " Inspect runner pane
  map <Leader>vi :VimuxInspectRunner<CR>
  " Zoom the tmux runner pane
  map <Leader>vz :VimuxZoomRunner<CR>
endif

if s:has_plugin('winresizer')
  let g:winresizer_start_key = '<C-T>'
endif

if s:has_plugin('vim-closetag')
  let g:closetag_emptyTags_caseSensitive = 1
  let g:closetag_filetypes = 'html,xhtml,phtml,javascript,typescriptreact'
endif

if s:has_plugin('vim-cutlass')
  nnoremap x d
  xnoremap x d
  nnoremap xx dd
  nnoremap X D
endif

if s:has_plugin('indentLine')
  let g:indentLine_setConceal = 0
endif

if s:has_plugin('vim-gutentags')
  let g:gutentags_ctags_tagfile = '.git/tags'
endif

if s:has_plugin('vim-subversive')
  nmap s <plug>(SubversiveSubstitute)
  nmap ss <plug>(SubversiveSubstituteLine)
  nmap S <plug>(SubversiveSubstituteToEndOfLine)
endif

if s:has_plugin('vim-yoink')
  let g:yoinkIncludeDeleteOperations = 1

  nmap <c-n> <plug>(YoinkPostPasteSwapBack)
  nmap <c-p> <plug>(YoinkPostPasteSwapForward)

  nmap p <plug>(YoinkPaste_p)
  nmap P <plug>(YoinkPaste_P)
endif

if s:has_plugin('notational-fzf-vim')
  nnoremap <silent><Leader>m :NV<CR>
  let g:nv_search_paths = ['~/Dropbox/wiki', '~/Dropbox/journal', '~/Dropbox/notes']
endif

if s:has_plugin('vim-gitgutter')
  let g:gitgutter_map_keys = 0
  let g:gitgutter_preview_win_floating = 0
  nmap ]c <Plug>(GitGutterNextHunk)
  nmap [c <Plug>(GitGutterPrevHunk)
  nmap <leader>hs <Plug>(GitGutterStageHunk)
  nmap <leader>hu <Plug>(GitGutterUndoHunk)
  nmap <leader>hp <Plug>(GitGutterPreviewHunk)
endif

if s:has_plugin('goyo.vim')
  nnoremap <silent><Leader>z :Goyo<CR>
endif

if s:has_plugin('vim-highlightedyank')
  let g:highlightedyank_highlight_duration = 200
endif
