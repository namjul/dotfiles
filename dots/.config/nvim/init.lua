-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

----------------------------------------
-- Aliases
----------------------------------------

local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local inspect = vim.inspect -- pretty-print Lua objects (useful for inspecting tables)
local util = require('namjul.utils')
local paq = util.paq
local opt = util.opt
local map = util.map
local var = util.var
local hasPlugin = util.hasPlugin

-- tabline = '%!v:lua.require(\'namjul.tabline\').line()' results in an error reported here https://github.com/neovim/neovim/issues/13862
function _G.mytabline()
  return require('namjul.tabline').line()
end

----------------------------------------
-- Options
----------------------------------------

-- Global
opt.g({
  mouse = 'a', -- Enable Mouse clicking
  shortmess = table.concat({
    't', -- truncate file message if too long to prevent 'Press Enter' message
    'A', -- ignore annoying swapfile messages
    'I', -- Don’t show the intro message when starting Vim
    'O', -- file-read message overwrites previous
  }, ''),
  visualbell = true, --  Use visual bell instead of audible bell
  backupcopy = 'yes', -- optimize webpack watch option and also crontab editing
  clipboard = 'unnamedplus',
  ignorecase = true,
  smartcase = true,
  wildignorecase = true,
  hidden = true,
  termguicolors = true, -- Enable term 24 bit colour
  gdefault = true, -- Add the g flag to search/replace by default
  background = 'dark',
  pastetoggle = '<F2>',
  tabline = '%!v:lua.mytabline()',
})

-- Window
opt.w({
  number = true, -- Show relative lines numbers
  cursorline = true, -- Highlight current line
  wrap = false, -- don't wrap lines
  list = true, -- show whitespaces
})

-- Buffer
opt.b({
  tabstop = 2, -- Make tabs as wide as two spaces
  shiftwidth = 2, -- The # of spaces for indenting.
  expandtab = true, -- use spaces, not tabs
})

----------------------------------------
-- Plugins
----------------------------------------

cmd('packadd paq-nvim') -- load the package manager

paq('wincent/pinnacle') -- Highlight group manipulation utils
paq({'savq/paq-nvim', opt = true}) -- Let Paq manage itself
paq('tpope/vim-sensible') -- sensible defaults
paq('tpope/vim-repeat') -- enables the repeat command to work with external plugins
paq('tpope/vim-fugitive') -- git integration
paq('rbong/vim-flog') -- git branch viewer
paq('tpope/vim-rhubarb') -- open files on github
paq('tpope/vim-surround') -- adds operators for surrounding characters
paq('tpope/vim-unimpaired') -- set of complementary pair commands
paq('tomtom/tcomment_vim') -- Temporarily commenting
paq('svermeulen/vim-cutlass') -- seperate `cut` form `delete`
paq('svermeulen/vim-subversive') -- adds a subsitute operator
paq('svermeulen/vim-yoink') -- adds easy access to history of yanks
paq('wincent/loupe') -- enhancements to vim's search commands
paq('wincent/scalpel') -- helper for search and replace
paq('editorconfig/editorconfig-vim') -- support editor config files (https://editorconfig.org/)
paq('tmux-plugins/vim-tmux-focus-events') -- makes `FocusGained` and `FocusLost` work in terminal vim, `autoread` options then works as expected
paq({'junegunn/fzf', hook = vim.fn['fzf#install'] }) -- fuzzy search
paq('junegunn/fzf.vim') -- adds commands to fzf
paq('junegunn/goyo.vim') -- zen mode for writing
paq('Yggdroot/indentLine') -- makes space indented code visible
paq('lukas-reineke/indent-blankline.nvim') --
paq('alok/notational-fzf-vim') -- combines the fzf with the concept from notational
paq('benmills/vimux') -- allows to send commands from vim to tmux
paq('tyewang/vimux-jest-test') -- simplifies running jest test from vim
paq('justinmk/vim-dirvish') -- file explorer
paq('jeffkreeftmeijer/vim-numbertoggle') -- improves the display of line numbers
paq('jiangmiao/auto-pairs') -- auto closes pairs
paq('Valloric/MatchTagAlways') -- highlights xml tags enclosing the cursor
paq('simeji/winresizer') -- helper for resizing windows
paq('camspiers/lens.vim') -- auto resizing of windows
paq('alvan/vim-closetag') -- auto closes the xml tag
paq('morhetz/gruvbox') -- colorscheme
-- paq('chriskempson/base16-vim')
-- paq('icymind/NeoSolarized')
-- paq('arcticicestudio/nord-vim')
-- paq('mhartington/oceanic-next')
-- paq('srcery-colors/srcery-vim')
-- paq('sonph/onehalf', { 'rtp': 'vim/' })
-- paq('drewtempelmeyer/palenight.vim')
-- paq('ayu-theme/ayu-vim')
-- paq('rakr/vim-one')
paq('airblade/vim-gitgutter') --- add info to sidebar about git
paq('rhysd/committia.vim') -- improves vim 'commit' buffer
paq('sheerun/vim-polyglot') -- general language support
paq('moll/vim-node') -- improves dx in node.js env
paq('SirVer/ultisnips') -- snippets engine
paq('honza/vim-snippets') -- general snippets collection
paq('mattn/gist-vim') -- interact with github gist from vim
paq('mattn/webapi-vim') -- needed for `gist-vim`
paq('dense-analysis/ale') -- linter, fixer and lsp
paq({ 'Shougo/deoplete.nvim',  hook = function () cmd('UpdateRemotePlugins') end }) -- autocomplete
paq('ap/vim-css-color') -- color name highlighter
paq('machakann/vim-highlightedyank') -- highlights yanked text
paq('dkarter/bullets.vim') -- enhance bullet points management
paq('csexton/trailertrash.vim') -- highlight trailing whitespace
paq('kassio/neoterm') -- simple terminal access

----------------------------------------
-- Custom Mappings
----------------------------------------

map.g('', 'Y', 'y$') -- multi-mode mappings (Normal, Visual, Operating-pending modes).

-- NORMAL
--------------------

map.g('n', 'Q', '') -- avoid unintentional switches to Ex mode.

-- move between windows.
map.g('n', '<C-h>', '<C-w>h')
map.g('n', '<C-j>', '<C-w>j')
map.g('n', '<C-k>', '<C-w>k')
map.g('n', '<C-l>', '<C-w>l')

-- store relative line number jumps in the jumplist if they exceed a threshold.
map.g('n', 'k', '(v:count > 5 ? "m\\\'" . v:count : "") . "k"', { expr = true })
map.g('n', 'j', '(v:count > 5 ? "m\\\'" . v:count : "") . "j"', { expr = true })


-- repurpose cursor keys (accessible near homerow via "SpaceFN" layout) for one
-- of my most oft-use key sequences.
map.g('n', '<Up>', ':cprevious<CR>', { silent = true })
map.g('n', '<Up>', ':cprevious<CR>', { silent = true })
map.g('n', '<Down>' , ':cnext<CR>', { silent = true })
map.g('n', '<Left>' , ':cpfile<CR>', { silent = true })
map.g('n', '<Right>' , ':cnfile<CR>', { silent = true })

map.g('n', '<S-Up>' , ':lprevious<CR>', { silent = true })
map.g('n', '<S-Down>' , ':lnext<CR>', { silent = true })
map.g('n', '<S-Left>' , ':lpfile<CR>', { silent = true })
map.g('n', '<S-Right>' , ':lnfile<CR>', { silent = true })

-- VISUAL
--------------------

-- move between windows.
map.g('x', '<C-h>', '<C-w>h')
map.g('x', '<C-j>', '<C-w>j')
map.g('x', '<C-k>', '<C-w>k')
map.g('x', '<C-l>', '<C-w>l')

-- COMMAND
--------------------

map.g('c', '<C-a>', '<Home>')
map.g('c', '<C-e>', '<End>')

-- INSERT
--------------------

-- esc mapping
map.g('i', 'jk', '<Esc>', { noremap = false })
map.g('i', '<C-K>', '<Esc>', { noremap = false })
map.g('i', '<C-c>', '<Esc>')

-- TERMINAL
--------------------

function _G.terminalEsc()
    return vim.bo.filetype == 'fzf' and util.t('<Esc>') or util.t('<C-\\><C-n>')
end
map.g('t', '<Esc>', 'v:lua.terminalEsc()', { expr = true })

-- LEADER
--------------------

-- set Space as leader
var.g({ mapleader = ' ' })
var.b({ mapleader = ' ' })

map.g('n', '<Leader><Leader>', '<C-^>') -- open last buffer.
map.g('n', '<Leader>o', ':only<CR>') -- close all windows but the active one
map.g('n', '<Leader>p', ':echo expand("%")<CR>') -- <Leader>p - Show the path of the current file (mnemonic: path; useful when you have a lot of splits and the status line gets truncated).
map.g('n', '<Leader>a', 'ggVG') -- select all
map.g('n', '<Leader>r', ':luafile $MYVIMRC<CR>') -- auto reload of vimrc TODO test in production env.

map.g('n', '<Leader>w', ':write<CR>') -- quick save
map.g('n', '<Leader>x', ':exit<CR>') -- like ":wq", but write only when changes have been
map.g('n', '<Leader>q', ':quit<CR>') -- quites the current window and vim if its the last

-- fzf mappings
map.g('n', '<Leader>*', ':Rg <C-R><C-W><CR>', { silent = true }) -- search for word under cursor
map.g('n', '<Leader>/', ':Rg<space>') -- search for word
map.g('n', '<Leader>f', ':Files<CR>', { silent = true }) -- search for file
map.g('n', '<Leader>b', ':Buffers<CR>', { silent = true }) -- search buffers
map.g('n', '<Leader>z', ':History<CR>', { silent = true }) -- search history - TODO clashes with GitGutter
map.g('n', '<Leader>c', ':Commands<CR>', { silent = true }) -- search commands

-- open new splits in a semantic way
map.g('n', '<Leader><C-h>', ':lefta vs new<CR>')
map.g('n', '<Leader><C-j>', ':below sp new<CR>')
map.g('n', '<Leader><C-k>', ':above sp new<CR>')
map.g('n', '<Leader><C-l>', ':rightb vsp new<CR>')

map.g('n', '<Leader>2', ':w<CR>:! ./%<CR>') -- execute current file

----------------------------------------
-- AUTO COMMANDS
----------------------------------------

util.createAugroup({
  { 'BufRead,BufNewFile', 'tsconfig.json', 'set', 'filetype=json5' },
  { 'BufRead,BufNewFile', 'eslintrc.json', 'set', 'filetype=json5' },
  { 'FileType', 'markdown', 'lua', 'require"namjul.autocmds".plainText()' }
}, 'namjulfiletypedetect')

util.createAugroup({
  { 'FileType', 'dirvish', 'silent! nnoremap <nowait><buffer><silent> o :<C-U>.call dirvish#open("edit", 0)<CR>' }, -- Overwrite default mapping for the benefit of my muscle memory. ('o' would normally open in a split window, but we want it to open in the current one.)
  { 'FileType', 'dirvish', 'nmap <buffer> q gq' }, -- close buffers using `gq`
  { 'FileType', 'dirvish', 'nmap <buffer>cd :cd %:p:h<CR>:pwd<CR>' } -- change directory wih `cd`
}, 'namjuldirvish')

util.createAugroup({
  { 'Colorscheme', '*', 'lua require"namjul.statusline".updateHighlight()' }, -- trigger highlight update see https://vi.stackexchange.com/questions/3355/why-do-custom-highlights-in-my-vimrc-get-cleared-or-reset-to-default
  { 'BufWinEnter,BufWritePost,FileWritePost,TextChanged,TextChangedI,WinEnter', '*', 'lua', 'require"namjul.statusline".checkModified()' }
}, 'namjulstatusline')

util.createAugroup({
  { 'BufEnter', '*', 'lua', 'require"namjul.autocmds".bufEnter()' },
  { 'BufLeave', '*', 'lua', 'require"namjul.autocmds".bufLeave()' },
  { 'BufWinEnter', '*', 'lua', 'require"namjul.autocmds".bufWinEnter()' },
  { 'BufWritePost', '*', 'lua', 'require"namjul.autocmds".bufWritePost()' },
  { 'FocusGained', '*', 'lua', 'require"namjul.autocmds".focusGained()' },
  { 'FocusLost', '*', 'lua', 'require"namjul.autocmds".focusLost()' },
  { 'InsertEnter', '*', 'lua', 'require"namjul.autocmds".insertEnter()' },
  { 'InsertLeave', '*', 'lua', 'require"namjul.autocmds".insertLeave()' },
  { 'VimEnter', '*', 'lua', 'require"namjul.autocmds".vimEnter()' },
  { 'WinEnter', '*', 'lua', 'require"namjul.autocmds".winEnter()' },
  { 'WinLeave', '*', 'lua', 'require"namjul.autocmds".winLeave()' },
  { 'InsertLeave', '*', 'set nopaste' }, --Disable paste mode on leaving insert mode.
}, 'namjulautocmds')

----------------------------------------
-- Plugin Settings
----------------------------------------

if hasPlugin('nord-vim') then
  cmd('colorscheme nord')
end

if hasPlugin('oceanic-next') then
  cmd('colorscheme OceanicNext')
  var.g({
    oceanic_next_terminal_bold = 1,
    oceanic_next_terminal_italic = 1
  })
end

if hasPlugin('srcery-vim') then
  cmd('colorscheme srcery')
  var.g({ srcery_italic = 1 })
end

if hasPlugin('onehalf') then
  cmd('colorscheme onehalfdark')
  cmd('highlight Comment cterm=italic gui=italic')
end


if hasPlugin('ayu-vim') then
  var.g({
    -- ayucolor = "light"  -- for light version of theme
    ayucolor = "mirage" -- for mirage version of theme
    -- ayucolor = "dark" -- for dark version of theme
  })
  cmd('colorscheme ayu')
end


if hasPlugin('vim-one') then
  cmd('colorscheme one')
  opt.g({ background = 'dark' })
end

if hasPlugin('gruvbox') then
  var.g({
    gruvbox_contrast_dark = 'soft',
    gruvbox_contrast_light = 'soft',
    gruvbox_italic = 1
  })
  opt.g({ background = 'dark' })
  cmd('colorscheme gruvbox')
end

if hasPlugin('ale') then
  var.g({
    ale_virtualtext_cursor = 1,
    ale_virtualtext_prefix = '❐ ',
    ale_echo_msg_format = '[%linter%] [%severity%] %code: %%s',
    ale_lint_on_text_changed = 'never',
    ale_linter_aliases = {
      javascriptreact = { 'javascript', 'jsx' },
      typescriptreact = { 'typescript', 'tsx' },
    },
    ale_linters = {
      typescript = { 'eslint', 'tsserver', 'typecheck' },
      javascript = { 'eslint', 'tsserver', 'flow' },
    },
    ale_fixers = {
      javascriptreact = { 'prettier' },
      typescriptreact = { 'prettier' },
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      html = { 'prettier' },
      json = { 'prettier' },
      mdx = { 'prettier' }
    },
    ale_javascript_prettier_use_local_config = 1,
    ale_sign_error="✖",
    ale_sign_warning="⚠",
    ale_sign_info="ℹ",
    ale_fix_on_save = 1,
  })

  cmd('highlight link ALEVirtualTextError GruvboxRed')
  cmd('highlight link ALEVirtualTextWarning GruvboxYellow')
  cmd('highlight link ALEVirtualTextInfo GruvboxBlue')

  map.g('n', '[g', '<Plug>(ale_previous_wrap)', { silent = true, noremap = false })
  map.g('n', ']g', '<Plug>(ale_next_wrap)', { silent = true, noremap = false })
  map.g('n', 'gD', '<Plug>(ale_go_to_type_definition)', { silent = true, noremap = false })
  map.g('n', 'gd', '<Plug>(ale_go_to_definition)', { silent = true, noremap = false })
  map.g('n', 'gr', '<Plug>(ale_find_references) :ALEFindReferences -relative<Return>', { silent = true, noremap = false })
  map.g('n', '<Leader>rn', '<Plug>(ale_rename)', { silent = true, noremap = false })

  function _G.showDocumentation()
    if (({ vim = true, lua = true, help = true })[vim.bo.filetype]) then
      fn.execute('h '..fn.expand('<cword>'))
    else
      cmd(':ALEHover')
    end
  end

  map.g('n', 'K', ':call v:lua.showDocumentation()<CR>', { noremap = true, silent = true }) -- Use K to show documentation in preview window.
end

if hasPlugin('deoplete.nvim') then
  var.g({ ['deoplete#enable_at_startup'] = 1 })
end

if hasPlugin('fzf.vim') then
  var.g({
    fzf_layout = { window = { width = 0.9, height = 1 } },
    fzf_action = {
      ['ctrl-t'] = 'tab split',
      ['ctrl-s'] = 'split',
      ['ctrl-v'] = 'vsplit',
    }
  })
end

if hasPlugin('neoterm') then
  var.g({ neoterm_autoinsert = 1 })
end

if hasPlugin('ultisnips') then
  var.g({ UltiSnipsExpandTrigger = '<C-j>' })
  var.g({ UltiSnipsJumpForwardTrigger = '<C-j>' })
  var.g({ UltiSnipsJumpBackwardTrigger = '<C-k>' })
end

if hasPlugin('vim-fugitive') then
  opt.g({ diffopt = opt.g('diffopt') .. ',vertical' })
  map.g('n', '<leader>gb', ':Gblame<CR>')
  map.g('n', '<leader>gs', ':Gstatus<CR>')
  map.g('n', '<leader>gc', ':Git commit -v<CR>')
  map.g('n', '<leader>ga', ':Git add -p<CR>')
  map.g('n', '<leader>gm', ':Git commit --amend<CR>')
  map.g('n', '<leader>gp', ':Git push<CR>')
  map.g('n', '<leader>gd', ':Gdiff<CR>')
  map.g('n', '<leader>gw', ':Gwrite<CR>')
  map.g('n', '<leader>gbr', ':Gbrowse<CR>')
end

if hasPlugin('vim-flog') then
  map.g('n', '<Leader>gf', ':Flog<CR>')
end

if hasPlugin('vim-polyglot') then
  var.g({ javascript_plugin_jsdoc = 1 })
  var.g({ javascript_plugin_flow = 1 })
  var.g({ vim_markdown_fenced_languages = { 'jsx=javascriptreact', 'js=javascript', 'tsx=typescriptreact', 'ts=typescriptreact' } })
  var.g({ vim_markdown_no_extensions_in_markdown = 1 })
  var.g({ vim_markdown_auto_insert_bullets = 0 })
  var.g({ vim_markdown_new_list_item_indent = 0 })
end

if hasPlugin('vimux') then
  map.g('n', '<Leader>vp', ':VimuxPromptCommand<CR>') -- Prompt for a command to run
  map.g('n', '<Leader>vl', ':VimuxRunLastCommand<CR>') -- Run last command executed by VimuxRunCommand
  map.g('n', '<Leader>vi', ':VimuxInspectRunner<CR>') -- Inspect runner pane
  map.g('n', '<Leader>vz', ':VimuxZoomRunner<CR>') -- Zoom the tmux runner pane
end

if hasPlugin('winresizer') then
  var.g({ winresizer_start_key = '<C-T>' })
end

if hasPlugin('vim-closetag') then
  var.g({ closetag_emptyTags_caseSensitive = 1 })
  var.g({ closetag_filetypes = 'html,xhtml,phtml,javascript,typescriptreact' })
end

if hasPlugin('vim-cutlass') then
  map.g('n', 'x', 'd')
  map.g('x', 'x', 'd')
  map.g('n', 'xx', 'dd')
  map.g('n', 'X', 'D')
end

if hasPlugin('indentLine') then
  var.g({ indentLine_setConceal = 0 })
end

if hasPlugin('vim-gutentags') then
  var.g({ gutentags_ctags_tagfile = '.git/tags' })
end

if hasPlugin('vim-subversive') then
  map.g('n', 's', '<plug>(SubversiveSubstitute)', { noremap = false })
  map.g('n', 'ss', '<plug>(SubversiveSubstituteLine)', { noremap = false })
  map.g('n', 'S', '<plug>(SubversiveSubstituteToEndOfLine)', { noremap = false })
end

if hasPlugin('vim-yoink') then
  var.g({ yoinkIncludeDeleteOperations = 1 })
  map.g('n', '<C-n>', '<Plug>(YoinkPostPasteSwapBack)', { noremap = false })
  map.g('n', '<C-p>', '<Plug>(YoinkPostPasteSwapForward)', { noremap = false })
  map.g('n', 'p', '<Plug>(YoinkPaste_p)', { noremap = false })
  map.g('n', 'P', '<Plug>(YoinkPaste_P)', { noremap = false })
end

if hasPlugin('notational-fzf-vim') then
  map.g('n', '<Leader>m', ':NV<CR>', { silent = true })
  var.g({ nv_search_paths = { '~/Dropbox/personal-wiki/wiki', '~/Dropbox/journal', '~/Dropbox/notes' } })
end

if hasPlugin('vim-gitgutter') then
  var.g({ gitgutter_map_keys = 0 })
  var.g({ gitgutter_preview_win_floating = 0 })
  map.g('n', ']c', '<Plug>(GitGutterNextHunk)', { noremap = false })
  map.g('n', '[c', '<Plug>(GitGutterPrevHunk)', { noremap = false })
  map.g('n', '<leader>hs', '<Plug>(GitGutterStageHunk)', { noremap = false })
  map.g('n', '<leader>hu', '<Plug>(GitGutterUndoHunk)', { noremap = false })
  map.g('n', '<leader>hp', '<Plug>(GitGutterPreviewHunk)', { noremap = false })
end

if hasPlugin('goyo.vim') then
  map.g('n', '<Leader>z', ':Goyo<CR>', { silent = true })
end

if hasPlugin('vim-highlightedyank') then
  var.g({ highlightedyank_highlight_duration = 200 })
end

if hasPlugin('tcomment_vim') then
  var.g({
    -- Prevent tcomment from making a zillion mappings (we just want the operator).
    tcomment_mapleader1 = '',
    tcomment_mapleader2 = '',
    tcomment_mapleader_comment_anyway = '',

    tcomment_mapleader_uncomment_anyway = 'gu', -- The default (g<) is a bit awkward to type.
    ['tcomment#filetype#guess_typescriptreact'] = 1, -- make embedded jsx work
  })
end

----------------------------------------
-- Custom Plugins
----------------------------------------

require('namjul.statusline').set()

