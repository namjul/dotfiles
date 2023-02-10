--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

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

function _G.P(...)
  vim.pretty_print(...)
end

----------------------------------------
-- Plugins requiring settings to exist
----------------------------------------

vim.g.nv_search_paths = {
  '~/Dropbox/dendron/wiki',
  '~/Dropbox/dendron/notes',
  '~/Dropbox/dendron/movement',
  '~/Dropbox/dendron/crm',
}
vim.g.nv_ignore_pattern = { 'assets', '.git' }
vim.g.winresizer_start_key = '<C-T>'
vim.g.VimuxOrientation = 'h'
vim.g.switch_mapping = ''

----------------------------------------
-- Plugins
----------------------------------------

local is_bootstrap = require('namjul.bootstrap').bootstrap_paq({
  'savq/paq-nvim',
  { 'tpope/vim-sensible', opt = true }, -- sensible defaults
  { 'tpope/vim-repeat', opt = true }, -- enables the repeat command to work with external plugins
  { 'tpope/vim-fugitive', opt = true }, -- git integration
  { 'rbong/vim-flog', opt = true }, -- git branch viewer
  { 'tpope/vim-rhubarb', opt = true }, -- open files on github
  { 'tpope/vim-unimpaired', opt = true }, -- set of complementary pair commands
  { 'tpope/vim-abolish', opt = true }, -- Case-preserving find and replace
  { 'kylechui/nvim-surround', opt = true }, -- adds operators for surrounding characters
  { 'numToStr/Comment.nvim' }, -- "gc" to comment visual regions/lines
  { 'svermeulen/vim-cutlass', opt = true }, -- seperate `cut` form `delete`
  { 'svermeulen/vim-subversive', opt = true }, -- adds a subsitute operator
  { 'nvim-lualine/lualine.nvim' }, -- fancier statusline
  { 'gbprod/yanky.nvim', opt = true }, -- adds easy access to history of yanks
  { 'tpope/vim-sleuth' }, -- support editor config files (https://editorconfig.org/)
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x' },
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  { 'ThePrimeagen/harpoon', opt = true }, -- navigation helper
  { 'junegunn/fzf', opt = true },
  { 'alok/notational-fzf-vim', opt = true }, -- combines the fzf with the concept from notational
  { 'preservim/vimux', opt = true }, -- allows to send commands from vim to tmux
  { 'tyewang/vimux-jest-test', opt = true }, -- simplifies running jest test from vim
  { 'tpope/vim-vinegar', opt = true }, -- file explorer TODO try again replacing with elihunter173/dirbuf.nvim
  { 'jeffkreeftmeijer/vim-numbertoggle', opt = true }, -- improves the display of line numbers
  { 'windwp/nvim-autopairs', opt = true }, -- auto closes pairs
  { 'Valloric/MatchTagAlways', opt = true }, -- highlights xml tags enclosing the cursor
  { 'simeji/winresizer', opt = true }, -- helper for resizing windows
  { 'lewis6991/gitsigns.nvim', opt = true },
  { 'rhysd/committia.vim', opt = true }, -- improves vim 'commit' buffer
  { 'L3MON4D3/LuaSnip', opt = true }, -- snippets engine
  { 'rafamadriz/friendly-snippets', opt = true }, -- general snippets collection
  { 'mattn/gist-vim', opt = true }, -- interact with github gist from vim
  { 'mattn/webapi-vim', opt = true }, -- needed for `gist-vim`
  { 'uga-rosa/ccc.nvim', opt = true }, -- Super powerful color picker / colorizer plugin.
  { 'dkarter/bullets.vim', opt = true }, -- enhance bullet points management TODO replace with 'gaoDean/autolist.nvim' when checkboxes are supported
  { 'csexton/trailertrash.vim', opt = true }, -- highlight trailing whitespace
  { 'godlygeek/tabular', opt = true }, -- auto alignment
  { 'tpope/vim-obsession', opt = true }, -- helper to start vim sessions
  { 'ellisonleao/glow.nvim', opt = true }, -- markdown preview
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update({ with_sync = true }))
    end,
    opt = true,
  },
  { 'windwp/nvim-ts-autotag', opt = true }, -- auto closes xml tags
  { 'ellisonleao/gruvbox.nvim', opt = true },
  { 'rafcamlet/nvim-luapad', opt = true },
  { 'folke/zen-mode.nvim', opt = true },
  { 'szw/vim-maximizer', opt = true },
  { 'airblade/vim-rooter', opt = true },
  { 'neovim/nvim-lspconfig', opt = true },
  { 'jose-elias-alvarez/null-ls.nvim', opt = true },
  { 'AndrewRadev/switch.vim', opt = true }, -- fast boolean switch
  { 'hrsh7th/nvim-cmp', opt = true },
  { 'hrsh7th/cmp-nvim-lsp', opt = true },
  { 'hrsh7th/cmp-path', opt = true },
  { 'hrsh7th/cmp-buffer', opt = true },
  { 'saadparwaiz1/cmp_luasnip', opt = true }, -- nvim-cmp source for Luasnip
  { 'namjul/dendron.nvim', opt = true },
  { 'mracos/mermaid.vim', opt = true },
  { 'folke/which-key.nvim', opt = true },
  { 'abecodes/tabout.nvim', opt = true }, -- tabbing out from parentheses, quotes, and similar contexts today.
  { 'rest-nvim/rest.nvim', opt = true }, -- http client in neovim
  { 'monaqa/dial.nvim', opt = true }, -- enhanced increment/decrement plugin for Neovim.
  { 'wsdjeg/vim-fetch', opt = true }, -- enables to process line and column jump specifications
  { 'andrewferrier/debugprint.nvim', opt = true },
  { 'michaelb/sniprun', opt = true, run = 'bash ./install.sh' },
  { 'folke/trouble.nvim', opt = true },
  { 'ggandor/leap.nvim', opt = true },
})

if is_bootstrap then
  return
end

if vim.o.loadplugins then
  util.loadPlugin('vim-abolish')
  util.loadPlugin('gruvbox.nvim')
  util.loadPlugin('yanky.nvim')
  util.loadPlugin('vim-sensible')
  util.loadPlugin('vim-unimpaired')
  util.loadPlugin('nvim-surround')
  util.loadPlugin('which-key.nvim')
  util.loadPlugin('bullets.vim')
  util.loadPlugin('switch.vim')
  util.loadPlugin('dial.nvim')
  util.loadPlugin('vim-cutlass')
  util.loadPlugin('vim-subversive')
  if not util.isVsCode() then
    util.loadPlugin('dendron.nvim')
    util.loadPlugin('vim-repeat')
    util.loadPlugin('vim-fugitive')
    util.loadPlugin('vim-flog')
    util.loadPlugin('vim-rhubarb')
    util.loadPlugin('harpoon')
    util.loadPlugin('fzf')
    util.loadPlugin('notational-fzf-vim')
    util.loadPlugin('vimux')
    util.loadPlugin('vimux-jest-test')
    util.loadPlugin('vim-vinegar')
    util.loadPlugin('vim-numbertoggle')
    util.loadPlugin('nvim-autopairs')
    util.loadPlugin('MatchTagAlways')
    util.loadPlugin('winresizer')
    util.loadPlugin('gitsigns.nvim')
    util.loadPlugin('committia.vim')
    util.loadPlugin('LuaSnip')
    util.loadPlugin('friendly-snippets')
    util.loadPlugin('gist-vim')
    util.loadPlugin('webapi-vim')
    util.loadPlugin('ccc.nvim')
    util.loadPlugin('trailertrash.vim')
    util.loadPlugin('tabular')
    util.loadPlugin('vim-obsession')
    util.loadPlugin('glow.nvim')
    util.loadPlugin('nvim-treesitter')
    util.loadPlugin('nvim-ts-autotag')
    util.loadPlugin('nvim-luapad')
    util.loadPlugin('zen-mode.nvim')
    util.loadPlugin('vim-maximizer')
    util.loadPlugin('vim-rooter')
    util.loadPlugin('nvim-lspconfig')
    util.loadPlugin('nvim-cmp')
    util.loadPlugin('cmp-nvim-lsp')
    util.loadPlugin('cmp-path')
    util.loadPlugin('cmp-buffer')
    util.loadPlugin('cmp_luasnip')
    util.loadPlugin('mermaid.vim')
    util.loadPlugin('tabout.nvim')
    util.loadPlugin('rest.nvim')
    util.loadPlugin('vim-fetch')
    util.loadPlugin('debugprint.nvim')
    util.loadPlugin('sniprun')
    util.loadPlugin('null-ls.nvim')
    util.loadPlugin('trouble.nvim')
    util.loadPlugin('leap.nvim')
  end
end

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
  vert = ' ',
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
  undofile = true, -- Maintain undo history between sessions
})

vim.cmd('colorscheme gruvbox')

if util.readable(vim.fn.expand('~/.vimrc_background')) then
  vim.cmd('source ~/.vimrc_background')
end

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

util.createAugroup({
  { 'BufRead', 'tsconfig*.json', 'set filetype=jsonc' },
  { 'BufNewFile', 'tsconfig*.json', 'set filetype=jsonc' },
}, 'JsoncFilterType')

require('namjul.translator')
require('namjul.keymaps')

-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = 'gruvbox',
    component_separators = '|',
    section_separators = '',
  },
})

-- Enable Comment.nvim
require('Comment').setup()
