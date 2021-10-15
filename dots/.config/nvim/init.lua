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
local opt = util.opt
local map = util.map
local var = util.var

----------------------------------------
-- Functions
----------------------------------------

-- markdown table alignment in lua
-- https://gist.github.com/tpope/287147
local function alignMdTable()
  local pattern = '^%s*|%s.*%s|%s*$'
  local lineNumber = fn.line('.')
  local currentColumn = fn.col('.')
  local previousLine = fn.getline(lineNumber - 1)
  local currentLine = fn.getline('.')
  local nextLine = fn.getline(lineNumber + 1)

  if
    fn.exists(':Tabularize')
    and currentLine:match('^%s*|')
    and (previousLine:match(pattern) or nextLine:match(pattern))
  then
    local column = #currentLine:sub(1, currentColumn):gsub('[^|]', '')
    local position = #fn.matchstr(currentLine:sub(1, currentColumn), '.*|\\s*\\zs.*')
    cmd('Tabularize/|/l1') -- `l` means left aligned and `1` means one space of cell padding
    cmd('normal! 0')
    fn.search(('[^|]*|'):rep(column) .. ('\\s\\{-\\}'):rep(position), 'ce', lineNumber)
  end
end

----------------------------------------
-- Global functions
----------------------------------------

-- tabline = '%!v:lua.require(\'namjul.tabline\').line()' results in an error reported here https://github.com/neovim/neovim/issues/13862
function _G.mytabline()
  return require('namjul.tabline').line()
end

_G.alignMdTable = alignMdTable

function _G.terminalEsc()
  return vim.bo.filetype == 'fzf' and util.t('<Esc>') or util.t('<C-\\><C-n>')
end

-- opens my daily note/journal page
function _G.openDailyJN(type)
  local path = os.getenv('HOME')
    .. '/Dropbox/'
    .. (type == 'journal' and type .. '/' .. os.date('%d.%m.%Y') or NOTATIONAL_FOLDER .. '/wiki/daily-notes')
    .. '.md'
  local command = ':e ' .. path
  if not util.fileExists(path) and type == 'journal' then
    command = command .. ' | 0r ~/.config/nvim/templates/journal-skeleton.md'
  end
  return command .. util.t('<CR>')
end

function _G.showDocumentation()
  if ({ vim = true, lua = true, help = true })[vim.bo.filetype] then
    fn.execute('h ' .. fn.expand('<cword>'))
  else
    cmd(':ALEHover')
  end
end

----------------------------------------
-- Plugins
----------------------------------------

-- start pre-plugin settings
var.g({ polyglot_disabled = { 'markdown' } })
-- end

-- install pag-nvim
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path })
end

require('paq')({
  'savq/paq-nvim',

  'tpope/vim-sensible', -- sensible defaults
  'svermeulen/vimpeccable', -- Neovim plugin that allows you to easily map keys directly to lua code inside your init.lua
  'wincent/pinnacle', -- Required for namjul.statusline. Highlight group manipulation utils
  'tpope/vim-repeat', -- enables the repeat command to work with external plugins
  'tpope/vim-fugitive', -- git integration
  'rbong/vim-flog', -- git branch viewer
  'tpope/vim-rhubarb', -- open files on github
  'tpope/vim-surround', -- adds operators for surrounding characters
  'tpope/vim-unimpaired', -- set of complementary pair commands
  'tomtom/tcomment_vim', -- Temporarily commenting
  'svermeulen/vim-cutlass', -- seperate `cut` form `delete`
  'svermeulen/vim-subversive', -- adds a subsitute operator
  'svermeulen/vim-yoink', -- adds easy access to history of yanks
  'wincent/loupe', -- enhancements to vim's search commands
  'wincent/scalpel', -- helper for search and replace
  'editorconfig/editorconfig-vim', -- support editor config files (https://editorconfig.org/)
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  'nvim-telescope/telescope-fzf-writer.nvim',
  -- 'lukas-reineke/indent-blankline.nvim',
  'junegunn/fzf',
  'alok/notational-fzf-vim', -- combines the fzf with the concept from notational

  'benmills/vimux', -- allows to send commands from vim to tmux
  'tyewang/vimux-jest-test', -- simplifies running jest test from vim
  'justinmk/vim-dirvish', -- file explorer
  'jeffkreeftmeijer/vim-numbertoggle', -- improves the display of line numbers
  'jiangmiao/auto-pairs', -- auto closes pairs
  'Valloric/MatchTagAlways', -- highlights xml tags enclosing the cursor
  'simeji/winresizer', -- helper for resizing windows
  'camspiers/lens.vim', -- auto resizing of windows
  -- 'morhetz/gruvbox'
  -- 'chriskempson/base16-vim'
  -- 'icymind/NeoSolarized'
  -- 'arcticicestudio/nord-vim'
  -- 'mhartington/oceanic-next'
  -- 'srcery-colors/srcery-vim'
  -- 'sonph/onehalf', { 'rtp': 'vim/' }
  -- 'drewtempelmeyer/palenight.vim'
  -- 'ayu-theme/ayu-vim'
  -- 'rakr/vim-one'
  'lewis6991/gitsigns.nvim',
  'rhysd/committia.vim', -- improves vim 'commit' buffer
  {
    'sheerun/vim-polyglot',
    disable = false, -- conflicts with treesitter indentation
  }, -- general language support
  'moll/vim-node', -- improves dx in node.js env
  'SirVer/ultisnips', -- snippets engine
  'honza/vim-snippets', -- general snippets collection
  'mattn/gist-vim', -- interact with github gist from vim
  'mattn/webapi-vim', -- needed for `gist-vim`
  -- 'dense-analysis/ale', -- linter, fixer and lsp
  'norcalli/nvim-colorizer.lua', -- The fastest Neovim colorizer.
  'machakann/vim-highlightedyank', -- highlights yanked text
  'dkarter/bullets.vim', -- enhance bullet points management
  'csexton/trailertrash.vim', -- highlight trailing whitespace
  'kassio/neoterm', -- simple terminal access
  'godlygeek/tabular', -- auto alignment
  { 'namjul/vim-markdown', branch = 'wikilinks' }, -- own fork of that adds wikilinks support
  'tpope/vim-obsession', -- helper to start vim sessions
  'ellisonleao/glow.nvim', -- markdown preview
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      vim.cmd('TSUpdate')
    end,
  },
  'windwp/nvim-ts-autotag', -- auto closes xml tags
  'rktjmp/lush.nvim', -- Define Neovim themes as a DSL in lua, with real-time feedback.
  'ellisonleao/gruvbox.nvim',
  'rafcamlet/nvim-luapad',
  'folke/zen-mode.nvim',
  'szw/vim-maximizer',
  'airblade/vim-rooter',
  'neovim/nvim-lspconfig',
  'AndrewRadev/switch.vim',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-buffer',
  'glepnir/lspsaga.nvim',
})

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
  undodir = os.getenv('XDG_DATA_HOME') .. '/nvim/undo',
})

-- Window
opt.w({
  number = true, -- Show relative lines numbers
  cursorline = true, -- Highlight current line
  wrap = false, -- don't wrap lines
  list = true, -- show whitespaces
  listchars = 'tab:>\\ ,trail:-,extends:>,precedes:<,nbsp:+',
})

-- Buffer
opt.b({
  tabstop = 2, -- Make tabs as wide as two spaces
  shiftwidth = 2, -- The # of spaces for indenting.
  expandtab = true, -- use spaces, not tabs
  undofile = true, -- Maintain undo history between sessions
})

vim.cmd('colorscheme gruvbox')

----------------------------------------
-- Custom Mappings
----------------------------------------

local vimp = require('vimp')

map.g('n', 'K', ':call v:lua.showDocumentation()<CR>', { noremap = true, silent = true }) -- Use K to show documentation in preview window.

-- LEADER
--------------------

-- set Space as leader
var.g({ mapleader = ' ' })
var.b({ mapleader = ' ' })

map.g('n', '<leader>a', 'ggVG') -- select all
map.g('n', '<leader><leader>', '<C-^>') -- open last buffer.
map.g('n', '<leader>o', ':only<CR>') -- close all windows but the active one

-- r = reload vimrc
vimp.nnoremap('<leader>r', function()
  -- Remove all previously added vimpeccable maps
  vimp.unmap_all()
  -- Unload the lua namespace so that the next time require('config.X') is called
  -- it will reload the file
  require('namjul.utils').unload_lua_namespace('namjul')
  -- Make sure all open buffers are saved
  vim.cmd('silent wa')
  -- Execute our vimrc lua file again to add back our maps
  dofile(vim.fn.stdpath('config') .. '/init.lua')

  print('Reloaded vimrc!')
end)

-- Show the path of the current file and add it to clipboard (mnemonic: path; useful when you have a lot of splits and the status line gets truncated).
vimp.nnoremap('<leader>p', function()
  local file = fn.join({ fn.expand('%'), fn.line('.') })
  cmd('let @+="' .. file .. '"')
  print(file)
end)

vimp.nnoremap('<leader>te', '<cmd>:Trans en<CR>')
vimp.nnoremap('<leader>tg', '<cmd>:Trans de<CR>')

map.g('n', '<leader>w', ':write<CR>') -- quick save
map.g('n', '<leader>x', ':exit<CR>') -- like ":wq", but write only when changes have been
map.g('n', '<leader>q', ':quit<CR>') -- quites the current window and vim if its the last

-- telescrope mappings
map.g(
  'n',
  '<leader>*',
  ":lua require('telescope.builtin').grep_string(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search for word under cursor
map.g(
  'n',
  '<leader>/',
  ":lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search for word
map.g('n', '<leader>f', ":lua require('namjul.telescope').findFiles()<CR>", { silent = true }) -- search for word under cursor
-- map.g(
--   'n',
--   '<leader>f',
--   ":lua require('telescope').extensions.fzf_writer.files(require('telescope.themes').get_ivy({}))<CR>",
--   { silent = true }
-- ) -- search for word under cursor
-- map.g(
--   'n',
--   '<leader>/',
--   ":lua require('telescope').extensions.fzf_writer.staged_grep(require('telescope.themes').get_ivy({}))<CR>",
--   { silent = true }
-- ) -- search for word under cursor
map.g(
  'n',
  '<leader>b',
  ":lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search buffers
map.g(
  'n',
  '<leader>c',
  ":lua require('telescope.builtin').commands(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search commands

-- open new splits in a semantic way
map.g('n', '<leader><C-h>', ':lefta vs new<CR>')
map.g('n', '<leader><C-j>', ':below sp new<CR>')
map.g('n', '<leader><C-k>', ':above sp new<CR>')
map.g('n', '<leader><C-l>', ':rightb vsp new<CR>')

map.g('n', '<leader>2', ':w<CR>:! ./%<CR>') -- execute current file

vimp.nnoremap('<leader>df', require('namjul.telescope').searchDotfiles)

map.g('n', '<leader>gb', ":lua require('telescope.builtin').git_branches()<CR>")

-- map.g('n', '<leader>d', 'v:lua.openDailyJN("note")', { expr = true })
-- map.g('n', '<leader>j', 'v:lua.openDailyJN("journal")', { expr = true })

map.g('', 'Y', 'y$') -- multi-mode mappings (Normal, Visual, Operating-pending modes).

-- PLUGIN:notational-fzf-vim
map.g('n', '<leader>l', ':NV<CR>', { silent = true })
-- PLUGIN:goyo.vim
map.g('n', '<leader>z', ':ZenMode<CR>', { silent = true })

-- PLUGIN:vim-maximizer
map.g('n', '<leader>m', ':MaximizerToggle<CR>', { silent = true })

-- moving text
map.g('v', 'J', ":m '>+1<CR>gv=gv")
map.g('v', 'K', ":m '<-2<CR>gv=gv")
map.g('i', '<C-j>', '<esc>:m .+1<CR>==')
map.g('i', '<C-k>', '<esc>:m .-2<CR>==')
map.g('n', '<leader>k', ':m .-2<CR>==')
map.g('n', '<leader>j', ':m .+1<CR>==')

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
map.g('n', '<Down>', ':cnext<CR>', { silent = true })
map.g('n', '<Left>', ':cpfile<CR>', { silent = true })
map.g('n', '<Right>', ':cnfile<CR>', { silent = true })

map.g('n', '<S-Up>', ':lprevious<CR>', { silent = true })
map.g('n', '<S-Down>', ':lnext<CR>', { silent = true })
map.g('n', '<S-Left>', ':lpfile<CR>', { silent = true })
map.g('n', '<S-Right>', ':lnfile<CR>', { silent = true })

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

map.g('i', 'jk', '<Esc>', { noremap = false }) -- esc mapping
map.g('i', '<Bar>', '<Bar><Esc>:call v:lua.alignMdTable() <CR>a', { silent = true }) -- align markdown table

-- Undo break points
map.g('i', ',', ',<C-g>u')
map.g('i', '.', '.<C-g>u')
map.g('i', '!', '!<C-g>u')
map.g('i', '?', '?<C-g>u')

-- TERMINAL
--------------------

map.g('t', '<Esc>', 'v:lua.terminalEsc()', { expr = true })

----------------------------------------
-- AUTO COMMANDS
----------------------------------------

util.createAugroup({
  { 'BufRead,BufNewFile', '*.json', 'set', 'filetype=jsonc' },
  { 'BufRead,BufNewFile', 'package.json', 'set', 'filetype=json' },
}, 'namjulfiletypedetect')

util.createAugroup({
  { 'Colorscheme', '*', 'lua require"namjul.statusline".updateHighlight()' }, -- trigger highlight update see https://vi.stackexchange.com/questions/3355/why-do-custom-highlights-in-my-vimrc-get-cleared-or-reset-to-default
  {
    'BufWinEnter,BufWritePost,FileWritePost,TextChanged,TextChangedI,WinEnter',
    '*',
    'lua',
    'require"namjul.statusline".checkModified()',
  },
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

util.createAugroup({
  { 'BufNewFile', '*.sh', 'lua', 'require"namjul.autocmds".skeleton("~/.config/nvim/templates/skeleton.sh")' },
  {
    'BufNewFile',
    '27.04.2021.md',
    'lua',
    'require"namjul.autocmds".skeleton("~/.config/nvim/templates/journal-morning-skeleton.md")',
  },
}, 'namjulskeletons')

----------------------------------------
-- Plugin Settings
----------------------------------------

-- PLUGIN:oceanic-next
-- cmd('colorscheme OceanicNext')
-- var.g({
--   oceanic_next_terminal_bold = 1,
--   oceanic_next_terminal_italic = 1
-- })

-- PLUGIN:srcery-vim
-- cmd('colorscheme srcery')
-- var.g({ srcery_italic = 1 })

-- PLUGIN:onehalf
-- cmd('colorscheme onehalfdark')
-- cmd('highlight Comment cterm=italic gui=italic')

-- PLUGIN:ayu-vim
-- var.g({
--   -- ayucolor = "light"  -- for light version of theme
--   ayucolor = "mirage" -- for mirage version of theme
--   -- ayucolor = "dark" -- for dark version of theme
-- })
-- cmd('colorscheme ayu')

-- PLUGIN:vim-one
-- cmd('colorscheme one')
-- opt.g({ background = 'dark' })

-- PLUGIN: zen-mode
require('zen-mode').setup({})

-- PLUGIN: vim-rooter
vim.g.rooter_patterns = { '.git' }

-- PLUGIN: winresizer
vim.g.winresizer_start_key = '<C-T>'

-- PLUGIN: notational-fzf-vim
vim.g.nv_search_paths = {
  '~/Dropbox/dendron/wiki',
  '~/Dropbox/dendron/notes',
  '~/Dropbox/dendron/movement',
  '~/Dropbox/dendron/crm',
}
vim.g.nv_ignore_pattern = { 'assets', '.git' }

-- PLUGIN: netrw
var.g({
  loaded_netrwPlugin = 1,
})

-- PLUGIN: gruvbox.nvim
var.g({
  gruvbox_contrast_dark = 'medium',
  gruvbox_contrast_light = 'medium',
  gruvbox_italic = 1,
})

-- PLUGIN: ale
-- var.g({
--   ale_virtualtext_cursor = 1,
--   ale_virtualtext_prefix = '❐ ',
--   ale_echo_msg_format = '[%linter%] [%severity%] %code: %%s',
--   ale_lint_on_text_changed = 'never',
--   ale_linter_aliases = {
--     javascriptreact = { 'javascript', 'jsx' },
--     typescriptreact = { 'typescript', 'tsx' },
--   },
--   ale_linters = {
--     typescript = { 'eslint', 'tsserver', 'typecheck' },
--     javascript = { 'eslint', 'tsserver', 'flow' },
--     json = {},
--     jsonc = {},
--   },
--   ale_fixers = {
--     javascriptreact = { 'prettier' },
--     typescriptreact = { 'prettier' },
--     javascript = { 'prettier' },
--     typescript = { 'prettier' },
--     html = { 'prettier' },
--     json = { 'prettier' },
--     mdx = { 'prettier' },
--     lua = { 'stylua' },
--   },
--   ale_lua_stylua_options = '--search-parent-directories',
--   ale_javascript_prettier_use_local_config = 1,
--   ale_sign_error = '✖',
--   ale_sign_warning = '⚠',
--   ale_sign_info = 'ℹ',
--   ale_fix_on_save = 1,
--   ale_disable_lsp = 1,
-- })
--
-- cmd('highlight link ALEVirtualTextError GruvboxRed')
-- cmd('highlight link ALEVirtualTextWarning GruvboxYellow')
-- cmd('highlight link ALEVirtualTextInfo GruvboxBlue')
--
-- map.g('n', '[g', '<Plug>(ale_previous_wrap)', { silent = true, noremap = false })
-- map.g('n', ']g', '<Plug>(ale_next_wrap)', { silent = true, noremap = false })

-- PLUGIN:neoterm
var.g({ neoterm_autoinsert = 1 })

-- PLUGIN:ultisnips
var.g({ UltiSnipsExpandTrigger = '<tab>' })
var.g({ UltiSnipsJumpForwardTrigger = '<C-j>' })
var.g({ UltiSnipsJumpBackwardTrigger = '<C-k>' })

-- PLUGIN: vim-fugitive
opt.g({ diffopt = opt.g('diffopt') .. ',vertical' })
map.g('n', '<leader>gs', ':Git<CR>')
map.g('n', '<leader>gc', ':Git commit -v<CR>')
map.g('n', '<leader>ga', ':Git add -p<CR>')
map.g('n', '<leader>gm', ':Git commit --amend<CR>')
map.g('n', '<leader>gp', ':Git push<CR>')
map.g('n', '<leader>gd', ':Gdiff<CR>')
map.g('n', '<leader>gw', ':Gwrite<CR>')
map.g('n', '<leader>gbr', ':GBrowse<CR>')

-- PLUGIN: vim-flog
map.g('n', '<leader>gf', ':Flog<CR>')

-- PLUGIN: vim-polyglot
-- vim-javascript
var.g({ javascript_plugin_jsdoc = 1 })
var.g({ javascript_plugin_flow = 1 })

-- vim-markdown
var.g({
  vim_markdown_fenced_languages = {
    'jsx=javascriptreact',
    'js=javascript',
    'tsx=typescriptreact',
    'ts=typescriptreact',
    'yarn=sh',
    'git=sh',
  },
  vim_markdown_no_extensions_in_markdown = 1,
  vim_markdown_new_list_item_indent = 0,
  vim_markdown_frontmatter = 1,
  vim_markdown_folding_disabled = 1,
})

-- PLUGIN: vimux
map.g('n', '<leader>vp', ':VimuxPromptCommand<CR>') -- Prompt for a command to run
map.g('n', '<leader>vl', ':VimuxRunLastCommand<CR>') -- Run last command executed by VimuxRunCommand
map.g('n', '<leader>vi', ':VimuxInspectRunner<CR>') -- Inspect runner pane
map.g('n', '<leader>vz', ':VimuxZoomRunner<CR>') -- Zoom the tmux runner pane

-- PLUGIN:vim-cutlass
map.g('n', 'x', 'd')
map.g('x', 'x', 'd')
map.g('n', 'xx', 'dd')
map.g('n', 'X', 'D')

-- PLUGIN:vim-subversive
map.g('n', 's', '<plug>(SubversiveSubstitute)', { noremap = false })
map.g('n', 'ss', '<plug>(SubversiveSubstituteLine)', { noremap = false })
map.g('n', 'S', '<plug>(SubversiveSubstituteToEndOfLine)', { noremap = false })

-- PLUGIN:yim-yoink
var.g({ yoinkIncludeDeleteOperations = 1 })
map.g('n', '<C-n>', '<Plug>(YoinkPostPasteSwapBack)', { noremap = false })
map.g('n', '<C-p>', '<Plug>(YoinkPostPasteSwapForward)', { noremap = false })
map.g('n', 'p', '<Plug>(YoinkPaste_p)', { noremap = false })
map.g('n', 'P', '<Plug>(YoinkPaste_P)', { noremap = false })

-- https://github.com/svermeulen/vim-yoink/issues/16#issuecomment-632234373
var.g({
  clipboard = {
    name = 'xsel_override',
    copy = {
      ['+'] = 'xsel --input --clipboard',
      ['*'] = 'xsel --input --primary',
    },
    paste = {
      ['+'] = 'xsel --output --clipboard',
      ['*'] = 'xsel --output --primary',
    },
    cache_enabled = 1,
  },
})

-- PLUGIN:vim-highlightedyank
var.g({ highlightedyank_highlight_duration = 200 })

-- PLUGIN:tcomment_vim
var.g({
  -- Prevent tcomment from making a zillion mappings (we just want the operator).
  tcomment_mapleader1 = '',
  tcomment_mapleader2 = '',
  tcomment_mapleader_comment_anyway = '',

  tcomment_mapleader_uncomment_anyway = 'gu', -- The default (g<) is a bit awkward to type.
  ['tcomment#filetype#guess_typescriptreact'] = 1, -- make embedded jsx work
})

-- PLUGIN:bullets.vim
var.g({ bullets_checkbox_markers = ' .oOX' })

-- PLUGIN:nvim-treesitter
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = {
    'tsx',
    'typescript',
    'javascript',
    'toml',
    'fish',
    'bash',
    'php',
    'json',
    'yaml',
    'html',
    'lua',
    'scss',
    'css',
  },
  autotag = {
    enable = true,
  },
})

-- PLUGIN:gitsigns.nvim
require('gitsigns').setup({
  current_line_blame = true,
  preview_config = {
    border = 'none',
  },
})

-- PLUGIN:telescope
local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    prompt_prefix = ' ',
    mappings = {
      i = {
        ['<esc>'] = actions.close,
        ['<C-q>'] = actions.send_to_qflist,
      },
    },
  },
})
require('telescope').load_extension('fzf')

-- PLUGIN:nvim-colorizer.lua #sdfsdfs
require('colorizer').setup()

-- PLUGIN:nvim-lspconfig
local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  -- opt.b({
  --   omnifunc = 'v:lua.vim.lsp.omnifunc',
  -- })

  -- Mappings.
  local opts = { silent = true }
  map.b('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev({ enable_popup = false })<CR>', opts)
  map.b('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next({ enable_popup = false })<CR>', opts)

  map.b('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  map.b('n', 'K', "<cmd>lua require'lspsaga.hover'.render_hover_doc()<CR>", opts)
  map.b('n', '<leader>rn', "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)
  map.b('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  map.b('n', 'gp', "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>", opts)
  map.b('n', '<leader>d', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
      spacing = 2,
      source = 'always',
      prefix = '',
    },
    underline = true,
    signs = true,
  })

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
end

vim.cmd([[
  sign define LspDiagnosticsSignError text=>> texthl=LspDiagnosticsSignError linehl= numhl=LspDiagnosticsDefaultError
  sign define LspDiagnosticsSignWarning text=>> texthl=LspDiagnosticsSignWarning linehl= numhl=LspDiagnosticsDefaultWarning
  sign define LspDiagnosticsSignInformation text=>> texthl=LspDiagnosticsSignInformation linehl= numhl=LspDiagnosticsDefaultInformation
  sign define LspDiagnosticsSignHint text=>> texthl=LspDiagnosticsSignHint linehl= numhl=LspDiagnosticsDefaultInformation
]])

-- setup typescript
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- https://github.com/neovim/nvim-lspconfig/issues/960#issuecomment-857087882
-- also checkout https://www.reddit.com/r/neovim/comments/og1cdv/neovim_lsp_how_do_you_get_diagnostic_mesages_to/

nvim_lsp.tsserver.setup({
  -- capabilities = capabilities,
  on_attach = on_attach,
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  flags = {
    debounce_text_changes = 150,
  },
})

-- setup diagnostics with errorformat (efm)
-- for available options see https://github.com/mattn/efm-langserver/blob/master/langserver/handler.go#L53
local eslint = {
  prefix = 'eslint',
  lintCommand = 'npx eslint -f visualstudio --stdin --stdin-filename ${INPUT}',
  lintFormats = { '%f(%l,%c): %tarning %m', '%f(%l,%c): %rror %m' }, -- see https://eslint.org/docs/user-guide/formatters/#visualstudio formatter, https://github.com/reviewdog/errorformat
  lintIgnoreExitCode = true,
  lintStdin = true,
}

local stylua = {
  prefix = 'stylua',
  formatCommand = 'stylua --search-parent-directories --stdin-filepath=${INPUT} -',
  formatStdin = true,
}

local prettier = {
  formatCommand = 'npx prettier --stdin-filepath=${INPUT}',
  formatStdin = true,
}

nvim_lsp.efm.setup({
  -- cmd = { 'efm-langserver', '-logfile', '/tmp/efm.log', '-loglevel', '5' },
  init_options = { documentFormatting = true },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'lua',
    'markdown',
  },
  root_dir = function(fname)
    return nvim_lsp.util.root_pattern('tsconfig.json')(fname)
      or nvim_lsp.util.root_pattern('.eslintrc.js', '.git')(fname)
  end,
  settings = {
    rootMarkers = { '.eslintrc.js', '.git/' },
    languages = {
      typescript = { prettier, eslint },
      javascript = { prettier, eslint },
      typescriptreact = { prettier, eslint },
      javascriptreact = { prettier, eslint },
      ['javascript.jsx'] = { prettier, eslint },
      ['typescript.tsx'] = { prettier, eslint },
      lua = { stylua },
      markdown = { prettier },
    },
  },
})

-- nnoremap <silent> ff    <cmd>lua vim.lsp.buf.formatting()<CR>
-- autocmd BufWritePre *.go lua vim.lsp.buf.formatting()

-- PLUGIN: nvim-cmp
local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
  },
  documentation = {
    border = {
      '🭽',
      '▔',
      '🭾',
      '▕',
      '🭿',
      '▁',
      '🭼',
      '▏',
    },
  },
})

----------------------------------------
-- Custom Plugins
----------------------------------------

require('namjul.statusline').set()
require('namjul.translator')
