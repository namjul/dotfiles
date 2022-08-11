--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
-- local inspect = vim.inspect -- pretty-print Lua objects (useful for inspecting tables)
local util = require('namjul.utils')
local opt = util.opt

----------------------------------------
-- Global functions
----------------------------------------

-- tabline = '%!v:lua.require(\'namjul.tabline\').line()' results in an error reported here https://github.com/neovim/neovim/issues/13862
function _G.mytabline()
  return require('namjul.tabline').line()
end

function _G.alignMdTable()
  return require('namjul.functions.alignMdTable')()
end

----------------------------------------
-- Global variables
----------------------------------------

util.var.g({
  loaded_netrwPlugin = 1,
})

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
  'tpope/vim-abolish', -- Case-preserving find and replace
  'tomtom/tcomment_vim', -- Temporarily commenting
  'svermeulen/vim-cutlass', -- seperate `cut` form `delete`
  'svermeulen/vim-subversive', -- adds a subsitute operator
  'svermeulen/vim-yoink', -- adds easy access to history of yanks
  'wincent/loupe', -- enhancements to vim's search commands
  'wincent/scalpel', -- helper for search and replace
  'gpanders/editorconfig.nvim', -- support editor config files (https://editorconfig.org/)
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  'nvim-telescope/telescope-fzf-writer.nvim',
  'ThePrimeagen/harpoon', -- navigation helper
  'junegunn/fzf',
  'alok/notational-fzf-vim', -- combines the fzf with the concept from notational
  'benmills/vimux', -- allows to send commands from vim to tmux
  'tyewang/vimux-jest-test', -- simplifies running jest test from vim
  'justinmk/vim-dirvish', -- file explorer
  'jeffkreeftmeijer/vim-numbertoggle', -- improves the display of line numbers
  'jiangmiao/auto-pairs', -- auto closes pairs
  'Valloric/MatchTagAlways', -- highlights xml tags enclosing the cursor
  'simeji/winresizer', -- helper for resizing windows
  'lewis6991/gitsigns.nvim',
  'rhysd/committia.vim', -- improves vim 'commit' buffer
  'moll/vim-node', -- improves dx in node.js env
  'L3MON4D3/LuaSnip', -- snippets engine
  'rafamadriz/friendly-snippets', -- general snippets collection
  'mattn/gist-vim', -- interact with github gist from vim
  'mattn/webapi-vim', -- needed for `gist-vim`
  'norcalli/nvim-colorizer.lua', -- The fastest Neovim colorizer.
  'machakann/vim-highlightedyank', -- highlights yanked text
  'dkarter/bullets.vim', -- enhance bullet points management
  'csexton/trailertrash.vim', -- highlight trailing whitespace
  'kassio/neoterm', -- simple terminal access
  'godlygeek/tabular', -- auto alignment
  -- { 'namjul/vim-markdown', branch = 'wikilinks' }, -- own fork of that adds wikilinks support
  'tpope/vim-obsession', -- helper to start vim sessions
  'ellisonleao/glow.nvim', -- markdown preview
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      vim.cmd('TSUpdate')
    end,
  },
  'windwp/nvim-ts-autotag', -- auto closes xml tags
  'ellisonleao/gruvbox.nvim',
  'rafcamlet/nvim-luapad',
  'folke/zen-mode.nvim',
  'szw/vim-maximizer',
  'airblade/vim-rooter',
  'neovim/nvim-lspconfig',
  'creativenull/efmls-configs-nvim',
  'AndrewRadev/switch.vim',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-buffer',
  'saadparwaiz1/cmp_luasnip', -- nvim-cmp source for Luasnip
  'kevinoid/vim-jsonc',
  -- { 'oberblastmeister/neuron.nvim', branch = 'unstable' },
  'namjul/dendron.nvim',
  'mracos/mermaid.vim',
  'folke/which-key.nvim',
  'abecodes/tabout.nvim', -- tabbing out from parentheses, quotes, and similar contexts today.
  'rest-nvim/rest.nvim', -- http client in neovim
  'monaqa/dial.nvim'
})

-- vim.opt.runtimepath:append '~/code/dendron.nvim'  -- Use an absolute path

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
  guifont = 'Cascadia_Code',
  completeopt = 'menu,menuone,noselect',
})

-- opt.g currenlty does not support tables
vim.opt.fillchars = {
  vert = " ",
}

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
