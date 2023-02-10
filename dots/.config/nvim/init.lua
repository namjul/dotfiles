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
  { 'tpope/vim-sensible' }, -- sensible defaults
  { 'tpope/vim-repeat' }, -- enables the repeat command to work with external plugins
  { 'tpope/vim-fugitive' }, -- git integration
  { 'rbong/vim-flog' }, -- git branch viewer
  { 'tpope/vim-rhubarb' }, -- open files on github
  { 'tpope/vim-unimpaired' }, -- set of complementary pair commands
  { 'tpope/vim-abolish' }, -- Case-preserving find and replace
  { 'kylechui/nvim-surround' }, -- adds operators for surrounding characters
  { 'numToStr/Comment.nvim' }, -- "gc" to comment visual regions/lines
  { 'svermeulen/vim-cutlass' }, -- seperate `cut` form `delete`
  { 'svermeulen/vim-subversive' }, -- adds a subsitute operator
  { 'nvim-lualine/lualine.nvim' }, -- fancier statusline
  { 'gbprod/yanky.nvim' }, -- adds easy access to history of yanks
  { 'tpope/vim-sleuth' }, -- support editor config files (https://editorconfig.org/)
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x' },
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  { 'ThePrimeagen/harpoon' }, -- navigation helper
  { 'junegunn/fzf' },
  { 'alok/notational-fzf-vim' }, -- combines the fzf with the concept from notational
  { 'preservim/vimux' }, -- allows to send commands from vim to tmux
  { 'tyewang/vimux-jest-test' }, -- simplifies running jest test from vim
  { 'tpope/vim-vinegar' }, -- file explorer TODO try again replacing with elihunter173/dirbuf.nvim
  { 'jeffkreeftmeijer/vim-numbertoggle' }, -- improves the display of line numbers
  { 'windwp/nvim-autopairs' }, -- auto closes pairs
  { 'Valloric/MatchTagAlways' }, -- highlights xml tags enclosing the cursor
  { 'simeji/winresizer' }, -- helper for resizing windows
  { 'lewis6991/gitsigns.nvim' },
  { 'rhysd/committia.vim' }, -- improves vim 'commit' buffer
  { 'L3MON4D3/LuaSnip' }, -- snippets engine
  { 'rafamadriz/friendly-snippets' }, -- general snippets collection
  { 'mattn/webapi-vim' }, -- needed for `gist-vim`
  { 'mattn/gist-vim' }, -- interact with github gist from vim
  { 'uga-rosa/ccc.nvim' }, -- Super powerful color picker / colorizer plugin.
  { 'dkarter/bullets.vim' }, -- enhance bullet points management TODO replace with 'gaoDean/autolist.nvim' when checkboxes are supported
  { 'csexton/trailertrash.vim' }, -- highlight trailing whitespace
  { 'godlygeek/tabular' }, -- auto alignment
  { 'tpope/vim-obsession' }, -- helper to start vim sessions
  { 'ellisonleao/glow.nvim' }, -- markdown preview
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update({ with_sync = true }))
    end,
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'windwp/nvim-ts-autotag' }, -- auto closes xml tags
  { 'ellisonleao/gruvbox.nvim' },
  { 'rafcamlet/nvim-luapad' },
  { 'folke/zen-mode.nvim' },
  { 'szw/vim-maximizer' },
  { 'airblade/vim-rooter' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'jose-elias-alvarez/null-ls.nvim' },
  { 'j-hui/fidget.nvim' },
  { 'folke/neodev.nvim' },
  { 'AndrewRadev/switch.vim' }, -- fast boolean switch
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-buffer' },
  { 'saadparwaiz1/cmp_luasnip' }, -- nvim-cmp source for Luasnip
  { 'namjul/dendron.nvim' },
  { 'mracos/mermaid.vim' },
  { 'folke/which-key.nvim' },
  { 'abecodes/tabout.nvim' }, -- tabbing out from parentheses, quotes, and similar contexts today.
  { 'rest-nvim/rest.nvim' }, -- http client in neovim
  { 'monaqa/dial.nvim' }, -- enhanced increment/decrement plugin for Neovim.
  { 'wsdjeg/vim-fetch' }, -- enables to process line and column jump specifications
  { 'andrewferrier/debugprint.nvim' },
  { 'michaelb/sniprun' },
  { 'ggandor/leap.nvim' },
})

if is_bootstrap then
  return
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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
