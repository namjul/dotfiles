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

function _G.alignMdTable()
  return require('namjul.functions.alignMdTable')()
end

function _G.P(...)
  vim.pretty_print(...)
end

----------------------------------------
-- Plugins requiring settings to exist
----------------------------------------

vim.g.winresizer_start_key = '<C-T>'
vim.g.VimuxOrientation = 'h'
vim.g.switch_mapping = ''
vim.g.trailertrash_blacklist = { 'mason' }
vim.g.markdown_composer_open_browser = 0

----------------------------------------
-- Plugins
----------------------------------------

local is_bootstrap = require('namjul.bootstrap').bootstrap_paq({
  { 'savq/paq-nvim' },
  { 'tpope/vim-sensible' }, -- sensible defaults
  { 'tpope/vim-repeat' }, -- enables the repeat command to work with external plugins
  { 'tpope/vim-fugitive' }, -- git integration
  -- { 'rbong/vim-flog' },            -- git branch viewer
  { 'tpope/vim-rhubarb' }, -- open files on github
  { 'tpope/vim-unimpaired' }, -- set of complementary pair commands
  { 'tpope/vim-abolish' }, -- Case-preserving find and replace
  { 'numToStr/Comment.nvim' }, -- "gc" to comment visual regions/lines
  { 'svermeulen/vim-cutlass' }, -- seperate `cut` form `delete`
  { 'svermeulen/vim-subversive' }, -- adds a subsitute operator
  { 'nvim-lualine/lualine.nvim' }, -- fancier statusline
  { 'gbprod/yanky.nvim' }, -- adds easy access to history of yanks
  { 'tpope/vim-sleuth' }, -- support editor config files (https://editorconfig.org/)
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x' },
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
  { 'rafamadriz/friendly-snippets' }, -- general snippets collection
  { 'mattn/webapi-vim' }, -- needed for `gist-vim`
  { 'mattn/gist-vim' }, -- interact with github gist from vim
  { 'uga-rosa/ccc.nvim' }, -- Super powerful color picker / colorizer plugin.
  -- { 'dkarter/bullets.vim' }, -- enhance bullet points management TODO replace with 'gaoDean/autolist.nvim' when checkboxes are supported
  { 'csexton/trailertrash.vim' }, -- highlight trailing whitespace
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
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'stevearc/conform.nvim', branch = 'nvim-0.9' },
  { 'nvimtools/none-ls.nvim' },
  { 'j-hui/fidget.nvim', branch = 'legacy' }, -- Standalone UI for nvim-lsp progress
  { 'folke/neodev.nvim' },
  { 'AndrewRadev/switch.vim' }, -- fast boolean switch
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-buffer' },
  { 'saadparwaiz1/cmp_luasnip' }, -- nvim-cmp source for Luasnip
  { 'folke/which-key.nvim' },
  { 'abecodes/tabout.nvim' }, -- tabbing out from parentheses, quotes, and similar contexts today.
  -- { 'rest-nvim/rest.nvim' }, -- http client in neovim
  -- { 'monaqa/dial.nvim' },         -- enhanced increment/decrement plugin for Neovim.
  -- { 'wsdjeg/vim-fetch' },         -- enables to process line and column jump specifications
  -- { 'andrewferrier/debugprint.nvim' },
  { 'michaelb/sniprun', build = './install.sh' },
  { 'ggandor/leap.nvim' },
  { 'stevearc/overseer.nvim' },
  { 'stevearc/dressing.nvim' },
  -- { 'MunifTanjim/nui.nvim' },
  { 'luckasRanarison/nvim-devdocs' },
  { 'm-demare/hlargs.nvim' },
  { 'stevearc/oil.nvim' },
  { 'echasnovski/mini.nvim', branch = 'stable' },
  { 'andreshazard/vim-freemarker' },
})

if is_bootstrap then
  return
end

require('namjul.bootstrap').load('shellbot')

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
  background = 'light',
  pastetoggle = '<F2>',
  tabline = "%!v:lua.require('namjul.tabline').line()",
  undodir = os.getenv('XDG_DATA_HOME') .. '/nvim/undo',
  guifont = 'Cascadia_Code',
  completeopt = 'menu,menuone,noselect',
  textwidth = 80,
  showmode = false, -- hide status line at the bottom
  tabstop = 2, -- spaces per tab
  viewoptions = 'cursor,folds' -- save/restore just these (with `:{mk,load}view`)
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
  listchars = table.concat({
    'nbsp:⦸', -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
    'extends:»', -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
    'precedes:«', -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
    'tab:»·', -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7) + MIDLINE HORIZONTAL ELLIPSIS (U+22EF, UTF-8: E2 8B AF)
    'trail:•', -- BULLET (U+2022, UTF-8: E2 80 A2)
  }, ','),
})

-- Buffer
opt.b({
  undofile = true, -- Maintain undo history between sessions
})

require('gruvbox').setup()
vim.cmd('colorscheme gruvbox')

if util.readable(vim.fn.expand('~/.vimrc_background')) then
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

require('Comment').setup()

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

require('overseer').setup()
require('fidget').setup()
require('glow').setup()
require('nvim-devdocs').setup({})
require('oil').setup({
  keymaps = {
    ['<C-h>'] = false,
    -- ['<C-v>'] = 'actions.select_vsplit',
    ['<C-s>'] = 'actions.select_split',
    ['<C-p>'] = 'actions.copy_entry_path',
        ["~"] = "<cmd>edit $HOME<CR>",
        -- Mappings can be a function
        ["gd"] = function()
            require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
        end,
        -- You can pass additional opts to vim.keymap.set by using
        -- a table with the mapping as the first element.
        ["<leader>ff"] = {
            function()
                require("telescope.builtin").find_files({
                    cwd = require("oil").get_current_dir()
                })
            end,
            mode = "n",
            nowait = true,
            desc = "Find files in the current directory"
        },
        -- Mappings that are a string starting with "actions." will be
        -- one of the built-in actions, documented below.
        ["`"] = "actions.tcd",
        -- Some actions have parameters. These are passed in via the `opts` key.
        ["<leader>:"] = {
            "actions.open_cmdline",
            opts = {
                shorten_path = true,
                modify = ":h",
            },
            desc = "Open the command line with the current directory as an argument",
        },
  },
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true
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
require('mini.diff').setup()
require('mini.surround').setup({
 mappings = {
    add = 'gza', -- Add surrounding in Normal and Visual modes
    delete = 'gzd', -- Delete surrounding
    find = 'gzf', -- Find surrounding (to the right)
    find_left = 'gzF', -- Find surrounding (to the left)
    highlight = 'gzh', -- Highlight surrounding
    replace = 'gzr', -- Replace surrounding
    update_n_lines = 'gzn', -- Update `n_lines`
    suffix_last = 'l', -- Suffix to search with "prev" method
    suffix_next = 'n', -- Suffix to search with "next" method
  },
})

require('harpoon'):setup({
  default = {
    get_root_dir = function()
      local root_dir = vim.fs.dirname(vim.fs.find({ '.root' }, { upward = true })[1])
      if root_dir then
        return string.gsub(root_dir, '\n', '')
      end

      local root_git_dir = vim.fn.system('git rev-parse --show-toplevel')
      if vim.v.shell_error == 0 and root_git_dir ~= nil then
        return string.gsub(root_git_dir, '\n', '')
      end
      return vim.loop.cwd()
    end,
  },
})

vim.cmd("command! ChatBoT lua require'chatbot'.chatbot()")

require('nvim-ts-autotag').setup()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
