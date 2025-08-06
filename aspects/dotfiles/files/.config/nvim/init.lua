--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

if vim.loader then
  vim.loader.enable()
end

require('namjul')

----------------------------------------
-- Plugins requiring settings to exist
----------------------------------------

vim.g.winresizer_start_key = '<S-T>'
vim.g.VimuxOrientation = 'h'
vim.g.switch_mapping = ''
-- vim.g.trailertrash_blacklist = { 'mason' }
vim.g.markdown_composer_open_browser = 0

----------------------------------------
-- Plugins
----------------------------------------

local is_bootstrap = namjul.plugin.bootstrap({
  { 'savq/paq-nvim' },
  { 'tpope/vim-sensible' }, -- sensible defaults
  { 'tpope/vim-repeat' }, -- enables the repeat command to work with external plugins
  { 'tpope/vim-fugitive' }, -- git integration
  -- { 'rbong/vim-flog' },            -- git branch viewer
  { 'tpope/vim-rhubarb' }, -- open files on github
  { 'shumphrey/fugitive-gitlab.vim' }, -- open files on gitlab
  { 'tpope/vim-unimpaired' }, -- set of complementary pair commands
  { 'tpope/vim-abolish' }, -- Case-preserving find and replace
  { 'svermeulen/vim-cutlass' }, -- seperate `cut` form `delete`
  { 'svermeulen/vim-subversive' }, -- adds a subsitute operator
  { 'nvim-lualine/lualine.nvim' }, -- fancier statusline
  { 'gbprod/yanky.nvim' }, -- adds easy access to history of yanks
  { 'tpope/vim-sleuth' }, -- support editor config files (https://editorconfig.org/)
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.8' },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'ThePrimeagen/harpoon', branch = 'harpoon2' }, -- navigation helper
  { 'TobinPalmer/pastify.nvim' },
  { 'euclio/vim-markdown-composer' },
  { 'preservim/vimux' }, -- allows to send commands from vim to tmux
  { 'tyewang/vimux-jest-test' }, -- simplifies running jest test from vim
  { 'jeffkreeftmeijer/vim-numbertoggle' }, -- improves the display of line numbers
  { 'windwp/nvim-autopairs' }, -- auto closes pairs
  { 'Valloric/MatchTagAlways' }, -- highlights xml tags enclosing the cursor
  { 'simeji/winresizer' }, -- helper for resizing windows
  -- { 'lewis6991/gitsigns.nvim' },
  -- { 'rhysd/committia.vim' },               -- improves vim 'commit' buffer
  { 'L3MON4D3/LuaSnip' }, -- snippets engine
  { 'mattn/webapi-vim' }, -- needed for `gist-vim`
  { 'mattn/gist-vim' }, -- interact with github gist from vim
  -- { 'dkarter/bullets.vim' }, -- enhance bullet points management TODO replace with 'gaoDean/autolist.nvim' when checkboxes are supported
  -- { 'csexton/trailertrash.vim' }, -- highlight trailing whitespace
  { 'godlygeek/tabular' }, -- auto alignment
  { 'tpope/vim-obsession' }, -- helper to start vim sessions
  { 'ellisonleao/glow.nvim' }, -- markdown preview
  {
    'nvim-treesitter/nvim-treesitter',
    build = function()
      pcall(require('nvim-treesitter.install').update({ with_sync = true }))
    end,
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'nvim-treesitter/nvim-treesitter-context' },
  { 'windwp/nvim-ts-autotag' }, -- auto closes xml tags
  { 'ellisonleao/gruvbox.nvim' },
  { 'navarasu/onedark.nvim' },
  -- { 'rafcamlet/nvim-luapad' },
  { 'folke/zen-mode.nvim' },
  { 'szw/vim-maximizer' },
  { 'airblade/vim-rooter' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim', branch = 'v1.32.0' },
  { 'neovim/nvim-lspconfig' },
  { 'stevearc/conform.nvim', branch = 'nvim-0.9' },
  { 'nvimtools/none-ls.nvim' },
  { 'nvimtools/none-ls-extras.nvim' },
  { 'j-hui/fidget.nvim', branch = 'legacy' }, -- Standalone UI for nvim-lsp progress
  { 'folke/neodev.nvim' },
  { 'AndrewRadev/switch.vim' }, -- fast boolean switch
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-calc' },
  { 'saadparwaiz1/cmp_luasnip' }, -- nvim-cmp source for Luasnip
  { 'folke/which-key.nvim' },
  { 'abecodes/tabout.nvim' }, -- tabbing out from parentheses, quotes, and similar contexts today.
  -- { 'rest-nvim/rest.nvim' }, -- http client in neovim
  -- { 'monaqa/dial.nvim' },         -- enhanced increment/decrement plugin for Neovim.
  -- { 'wsdjeg/vim-fetch' },         -- enables to process line and column jump specifications
  -- { 'andrewferrier/debugprint.nvim' },
  { 'michaelb/sniprun', build = './install.sh' },
  -- { 'ggandor/leap.nvim' },
  { 'stevearc/overseer.nvim' },
  { 'stevearc/dressing.nvim' },
  -- { 'MunifTanjim/nui.nvim' },
  { 'm-demare/hlargs.nvim' },
  { 'stevearc/oil.nvim' },
  { 'echasnovski/mini.nvim', branch = 'main' },
  { 'andreshazard/vim-freemarker' },
  { 'subnut/nvim-ghost.nvim' },
  { 'nvim-tree/nvim-tree.lua', opt = true },
  { 'yousefakbar/notmuch.nvim', opt = true },
  { 'mbbill/undotree', opt = true }
})

if is_bootstrap then
  return
end

namjul.plugin.load('shellbot')

----------------------------------------
-- Options
----------------------------------------

-- local home = vim.env.HOME
-- local config = home .. '/.config/nvim'
local root = vim.env.USER == 'root'
local vi = vim.v.progname == 'vi'

vim.opt.autoindent = true -- maintain indent of current line
vim.opt.backspace = 'indent,start,eol' -- allow unrestricted backspacing in insert mode
vim.opt.backup = false -- don't make backups before writing
vim.opt.backupcopy = 'yes' -- overwrite files to update, instead of renaming + rewriting
-- vim.opt.backupdir = config .. '/backup//' -- keep backup files out of the way (ie. if 'backup' is ever set)
-- vim.opt.backupdir = vim.opt.backupdir + '.' -- fallback
-- vim.opt.backupskip = vim.opt.backupskip + '*.re,*.rei' -- prevent bsb's watch mode from getting confused (if 'backup' is ever set)
vim.opt.belloff = 'all' -- never ring the bell for any reason
vim.opt.completeopt = 'menu' -- show completion menu (for nvim-cmp)
vim.opt.completeopt = vim.opt.completeopt + 'menuone' -- show menu even if there is only one candidate (for nvim-cmp)
vim.opt.completeopt = vim.opt.completeopt + 'noselect' -- don't automatically select canditate (for nvim-cmp)
vim.opt.cursorline = true -- highlight current line
-- vim.opt.diffopt = vim.opt.diffopt + 'foldcolumn:0' -- don't show fold column in diff view
-- vim.opt.directory = config .. '/nvim/swap//' -- keep swap files out of the way
-- vim.opt.directory = vim.opt.directory + '.' -- fallback
vim.opt.emoji = false -- don't assume all emoji are double width
vim.opt.expandtab = true -- always use spaces instead of tabs
vim.opt.fillchars = {
  diff = '∙', -- BULLET OPERATOR (U+2219, UTF-8: E2 88 99)
  eob = ' ', -- NO-BREAK SPACE (U+00A0, UTF-8: C2 A0) to suppress ~ at EndOfBuffer
  fold = '·', -- MIDDLE DOT (U+00B7, UTF-8: C2 B7)
  vert = ' ', -- BOX DRAWINGS LIGHT VERTICAL (U+2502, UTF-8: E2 94 82)
}
vim.opt.foldlevelstart = 99 -- start unfolded
vim.opt.foldmethod = 'indent' -- not as cool as syntax, but faster
-- vim.opt.foldtext = 'v:lua.wincent.foldtext()'
-- vim.opt.formatoptions = vim.opt.formatoptions + 'j' -- remove comment leader when joining comment lines
-- vim.opt.formatoptions = vim.opt.formatoptions + 'n' -- smart auto-indenting inside numbered lists
vim.opt.guifont = 'JetBrainsMonoNerdFont'
vim.opt.hidden = true -- allows you to hide buffers with unsaved changes without being prompted
vim.opt.inccommand = 'split' --  Preview substitutions live, as you type!
vim.opt.ignorecase = true -- ignore case in searches
vim.opt.joinspaces = false -- don't autoinsert two spaces after '.', '?', '!' for join command
vim.opt.laststatus = 2 -- always show status line
vim.opt.lazyredraw = true -- don't bother updating screen during macro playback
vim.opt.linebreak = true -- wrap long lines at characters in 'breakat'
vim.opt.list = true -- show whitespace
vim.opt.listchars = {
  nbsp = '⦸', -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
  extends = '»', -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
  precedes = '«', -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
  tab = '»·', -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7) + MIDLINE HORIZONTAL ELLIPSIS (U+22EF, UTF-8: E2 8B AF)
  trail = '•', -- BULLET (U+2022, UTF-8: E2 80 A2)
}
vim.opt.modelines = 5 -- scan this many lines looking for modeline
vim.opt.number = true -- show line numbers in gutter
vim.opt.pumheight = 20 -- max number of lines to show in pop-up menu
vim.opt.relativenumber = true -- show relative numbers in gutter
vim.opt.scrolloff = 3 -- start scrolling 3 lines before edge of viewport
vim.opt.shell = 'sh' -- shell to use for `!`, `:!`, `system()` etc.
vim.opt.shiftround = false -- don't always indent by multiple of shiftwidth
vim.opt.shiftwidth = 2 -- spaces per tab (when shifting)
vim.opt.shortmess = vim.opt.shortmess + 'A' -- ignore annoying swapfile messages
vim.opt.shortmess = vim.opt.shortmess + 'I' -- no splash screen
vim.opt.shortmess = vim.opt.shortmess + 'O' -- file-read message overwrites previous
vim.opt.shortmess = vim.opt.shortmess + 'T' -- truncate non-file messages in middle
vim.opt.shortmess = vim.opt.shortmess + 'W' -- don't echo "[w]"/"[written]" when writing
vim.opt.shortmess = vim.opt.shortmess + 'a' -- use abbreviations in messages eg. `[RO]` instead of `[readonly]`
vim.opt.shortmess = vim.opt.shortmess + 'c' -- completion messages
vim.opt.shortmess = vim.opt.shortmess + 'o' -- overwrite file-written messages
vim.opt.shortmess = vim.opt.shortmess + 't' -- truncate file messages at start
vim.opt.showbreak = '↳ ' -- DOWNWARDS ARROW WITH TIP RIGHTWARDS (U+21B3, UTF-8: E2 86 B3)
vim.opt.showcmd = false -- don't show extra info at end of command line
vim.opt.sidescroll = 0 -- sidescroll in jumps because terminals are slow
vim.opt.sidescrolloff = 3 -- same as scrolloff, but for columns
vim.opt.smartcase = true -- don't ignore case in searches if uppercase characters present
vim.opt.smarttab = true -- <tab>/<BS> indent/dedent in leading whitespace
if not vi then
  vim.opt.softtabstop = -1 -- use 'shiftwidth' for tab/bs at end of line
end
-- vim.opt.spellcapcheck = '' -- don't check for capital letters at start of sentence
vim.opt.splitright = true -- open vertical splits to the right of the current window
vim.opt.splitbelow = true -- open horizontal splits below current window
-- vim.opt.suffixes = vim.opt.suffixes - '.h' -- don't sort header files at lower priority
vim.opt.swapfile = false -- don't create swap files
vim.opt.switchbuf = 'usetab' -- try to reuse windows/tabs when switching buffers
vim.opt.synmaxcol = 200 -- don't bother syntax highlighting long lines
vim.opt.tabstop = 2 -- spaces per tab
vim.opt.termguicolors = true -- use guifg/guibg instead of ctermfg/ctermbg in terminal
vim.opt.textwidth = 120 -- automatically hard wrap at 80 columns
vim.opt.wrap = false
vim.opt.undofile = true -- actually use undo files
vim.opt.updatetime = 250 -- Decrease update time (CursorHold interval)
vim.opt.timeoutlen = 300 -- Decrease mapped sequence wait time
vim.opt.updatecount = 0 -- update swapfiles every 80 typed chars
vim.opt.viewoptions = 'cursor,folds' -- save/restore just these (with `:{mk,load}view`)
vim.opt.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode
vim.opt.visualbell = true -- stop annoying beeping for non-error errors
-- vim.opt.whichwrap = 'b,h,l,s,<,>,[,],~' -- allow <BS>/h/l/<Left>/<Right>/<Space>, ~ to cross line boundaries
-- vim.opt.wildcharm = 26 -- ('<C-z>') substitute for 'wildchar' (<Tab>) in macros
-- vim.opt.wildignore = vim.opt.wildignore + '*.o,*.rej,*.so' -- patterns to ignore during file-navigation
-- vim.opt.wildmenu = true -- show options as list when switching buffers etc
-- vim.opt.wildmode = 'longest:full,full' -- shell-like autocomplete to unambiguous portion
vim.opt.mouse = 'a' -- Enable Mouse clicking
vim.opt.gdefault = true -- Add the g flag to search/replace by default
vim.opt.background = 'light'
vim.opt.tabline = "%!v:lua.require('namjul.tabline').line()"
vim.opt.showmode = false -- Don't show the mode, since it's already in the status line

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

require('gruvbox').setup()
vim.cmd('colorscheme gruvbox')

if namjul.utils.readable(vim.fn.expand('~/.vimrc_background')) then
  vim.cmd('source ~/.vimrc_background')
end

require('dressing').setup({
  select = {
    telescope = require('telescope.themes').get_ivy({}),
  },
})

vim.filetype.add({
  extension = {
    mdx = 'mdx',
  },
})

require('namjul.translator')
require('namjul.keymaps')
require('namjul.lsp')
require('namjul.filetype')

-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = 'gruvbox',
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = { {
      'mode',
      fmt = function(value)
        return value:sub(1, 1)
      end,
    } },
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        separator = '',
        path = 1,
      },
      {
        'filetype',
        fmt = function(value)
          return (value:len() > 0) and '[' .. value .. ']' or ''
        end,
      },
    },
    lualine_x = { 'encoding', 'fileformat' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
})

-- require('clipboard-image').setup({
--   default = {
--     img_name = function()
--       vim.fn.inputsave()
--       local name = vim.fn.input('Name: ')
--       vim.fn.inputrestore()
--       return name
--     end,
--     img_dir = { '%:p:h', 'assets', 'images' },
--     img_dir_txt = './assets/images',
--   },
-- })

require('pastify').setup({
  opts = {
    absolute_path = false, -- use absolute or relative path to the working directory
    local_path = './assets/images', -- The path to put local files in, ex <cwd>/assets/images/<filename>.png
    save = 'local', -- Either 'local' or 'online' or 'local_file'
    filename = function()
      vim.fn.inputsave()
      local name = vim.fn.input('Name: ')
      vim.fn.inputrestore()
      return name
    end,
    default_ft = 'markdown', -- Default filetype to use
  },
})

require('fidget').setup()
require('glow').setup()
require('oil').setup({
  keymaps = {
    ['<C-p>'] = 'actions.copy_entry_path',
    -- Scope files lookup by current working directory
    ['<leader>ff'] = {
      function()
        namjul.functions.telescope.findFiles({
          cwd = require('oil').get_current_dir(),
        })
      end,
      mode = 'n',
      nowait = true,
      desc = 'Find files in the current directory',
    },
    ['<leader>:'] = {
      'actions.open_cmdline',
      opts = {
        shorten_path = true,
        modify = ':h',
      },
      desc = 'Open the command line with the current directory as an argument',
    },
  },
  delete_to_trash = true,
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    -- natural_order = true,
    is_always_hidden = function(name)
      return name == '..' or name == '.git'
    end
  }
})
require('hlargs').setup()
require('conform').setup({
  notify_on_error = false,
  format_on_save = false,
  formatters_by_ft = {
    lua = { 'stylua' },
    -- Conform will run multiple formatters sequentially
    -- python = { 'isort', 'black' },
    -- Use a sub-list to run only the first available formatter
    javascript = { { 'prettierd', 'prettier' } },
    typescript = { { 'prettierd', 'prettier' } },
  },
})
require('mini.diff').setup({
  view = {
    style = 'sign',
  }
})
require('mini.surround').setup({
  mappings = {
    add = 'sa', -- Add surrounding in Normal and Visual modes
    delete = 'sd', -- Delete surrounding
    find = 'sf', -- Find surrounding (to the right)
    find_left = 'sF', -- Find surrounding (to the left)
    highlight = 'sh', -- Highlight surrounding
    replace = 'sr', -- Replace surrounding
    update_n_lines = 'sn', -- Update `n_lines`
    suffix_last = 'l', -- Suffix to search with "prev" method
    suffix_next = 'n', -- Suffix to search with "next" method
  },
})

require('harpoon'):setup()

require('nvim-ts-autotag').setup()

namjul.plugin.lazy('nvim-tree.lua', {
  afterload = function()
    require('nvim-tree').setup({
      actions = {
        open_file = {
          window_picker = { enable = false }
        },
      },
      renderer = {
        indent_markers = {
          enable = true
        },
        icons = {
          show = {
            git = false,
            folder = false,
            folder_arrow = false,
          }
        },
        special_files = {
          enable = false
        }
      },
      git = {
        enable = false,
      },
    })
  end,
  commands = {
    'NvimTreeFindFile',
    'NvimTreeToggle',
    'NvimTreeOpen',
  },
  keymap = {
    { 'n', '<LocalLeader>f', ':NvimTreeFindFile<CR>', { silent = true } },
    { 'n', '<LocalLeader>t', ':NvimTreeToggle<CR>', { silent = true } },
  },
})

namjul.plugin.lazy('notmuch', {
  afterload = function()
    require('notmuch').setup({
      notmuch_db_path = "/home/hobl/.mail"
    })
  end,
  commands = {
    'Notmuch',
  }
})

namjul.plugin.lazy('overseer', {
  afterload = function()
    require('overseer').setup()
  end,
  commands = {
    'OverseerRun',
    'OverseerOpen',
    'OverseerToggle',
  },
  keymap = {
    { 'n', '<Leader>t', ':OverseerToggle<CR>', { silent = true } },
  },
})

namjul.plugin.lazy('undotree', {
  beforeload = function()
    vim.g.undotree_HighlightChangedText = 0
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_DiffCommand = 'diff -u'
  end,
  keymap = {
      { 'n', '<Leader>u', ':UndotreeToggle<CR>', { silent = true } },
    },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
