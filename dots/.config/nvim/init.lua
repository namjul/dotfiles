-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
-- local inspect = vim.inspect -- pretty-print Lua objects (useful for inspecting tables)
local util = require('namjul.utils')
local opt = util.opt

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
-- AUTO COMMANDS
----------------------------------------

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

require('namjul.mappings')
