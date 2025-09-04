--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

require('namjul')

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
  -- { 'svermeulen/vim-subversive' }, -- adds a subsitute operator
  { 'gbprod/yanky.nvim' }, -- adds easy access to history of yanks
  { 'tpope/vim-sleuth' }, -- support editor config files (https://editorconfig.org/)
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.8' },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'ThePrimeagen/harpoon', branch = 'harpoon2' }, -- navigation helper
  { 'TobinPalmer/pastify.nvim' },
  { 'euclio/vim-markdown-composer', build = 'cargo build --release'  },
  { 'preservim/vimux' }, -- allows to send commands from vim to tmux
  { 'tyewang/vimux-jest-test' }, -- simplifies running jest test from vim
  { 'jeffkreeftmeijer/vim-numbertoggle' }, -- improves the display of line numbers
  { 'Valloric/MatchTagAlways' }, -- highlights xml tags enclosing the cursor
  { 'simeji/winresizer' }, -- helper for resizing windows
  -- { 'lewis6991/gitsigns.nvim' },
  -- { 'rhysd/committia.vim' },               -- improves vim 'commit' buffer
  { 'L3MON4D3/LuaSnip', branch = 'v2.4.0' }, -- snippets engine
  { 'mattn/webapi-vim' }, -- needed for `gist-vim`
  { 'mattn/gist-vim' }, -- interact with github gist from vim
  -- { 'dkarter/bullets.vim' }, -- enhance bullet points management TODO replace with 'gaoDean/autolist.nvim' when checkboxes are supported
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
  { 'ellisonleao/gruvbox.nvim' },
  { 'navarasu/onedark.nvim' },
  -- { 'rafcamlet/nvim-luapad' },
  { 'folke/zen-mode.nvim' },
  { 'szw/vim-maximizer' },
  { 'airblade/vim-rooter' },
  { 'mason-org/mason.nvim' },
  { 'mason-org/mason-lspconfig.nvim' },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'stevearc/conform.nvim', branch = 'nvim-0.9' },
  { 'folke/neodev.nvim' },
  { 'AndrewRadev/switch.vim' }, -- fast boolean switch
  { 'saghen/blink.cmp', branch = 'v1.6.0' },
  { 'folke/which-key.nvim' },
  -- { 'rest-nvim/rest.nvim' }, -- http client in neovim
  -- { 'monaqa/dial.nvim' },         -- enhanced increment/decrement plugin for Neovim.
  -- { 'wsdjeg/vim-fetch' },         -- enables to process line and column jump specifications
  -- { 'andrewferrier/debugprint.nvim' },
  { 'michaelb/sniprun', build = './install.sh' },
  { 'stevearc/overseer.nvim' },
  -- { 'MunifTanjim/nui.nvim' },
  { 'm-demare/hlargs.nvim' },
  { 'stevearc/oil.nvim' },
  { 'echasnovski/mini.nvim', branch = 'main' },
  { 'andreshazard/vim-freemarker' },
  { 'subnut/nvim-ghost.nvim' },
  { 'nvim-tree/nvim-tree.lua', opt = true },
  { 'yousefakbar/notmuch.nvim', opt = true },
  { 'mbbill/undotree', opt = true },
  { 'mfussenegger/nvim-lint' },
  { 'windwp/nvim-ts-autotag' }
})

if is_bootstrap then
  return
end
