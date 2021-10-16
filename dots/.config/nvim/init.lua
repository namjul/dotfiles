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

----------------------------------------
-- Plugins
----------------------------------------

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
  'lewis6991/gitsigns.nvim',
  'rhysd/committia.vim', -- improves vim 'commit' buffer
  'moll/vim-node', -- improves dx in node.js env
  'SirVer/ultisnips', -- snippets engine
  'honza/vim-snippets', -- general snippets collection
  'quangnguyen30192/cmp-nvim-ultisnips', -- nvim-cmp source for ultisnips
  'mattn/gist-vim', -- interact with github gist from vim
  'mattn/webapi-vim', -- needed for `gist-vim`
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
  'kevinoid/vim-jsonc',
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
}, 'namjulskeletons')

----------------------------------------
-- Custom Plugins
----------------------------------------

require('namjul.statusline').set()
require('namjul.translator')
