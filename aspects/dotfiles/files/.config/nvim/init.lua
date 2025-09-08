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
  { 'tpope/vim-fugitive' }, -- git integration
  { 'shumphrey/fugitive-gitlab.vim' }, -- open files on gitlab
  { 'tpope/vim-abolish' }, -- Case-preserving find and replace
  { 'svermeulen/vim-cutlass' }, -- seperate `cut` form `delete`
  { 'tpope/vim-sleuth' }, -- support editor config files (https://editorconfig.org/)
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.8' },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'ThePrimeagen/harpoon', branch = 'harpoon2' }, -- navigation helper
  { 'TobinPalmer/pastify.nvim' },
  { 'iamcco/markdown-preview.nvim', build = function()
    vim.fn['mkdp#util#install']()
  end
  },
  { 'simeji/winresizer' }, -- helper for resizing windows
  { 'L3MON4D3/LuaSnip', branch = 'v2.4.0' }, -- snippets engine
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
  { 'saghen/blink.cmp', branch = 'v1.6.0' },
  -- { 'rest-nvim/rest.nvim' }, -- http client in neovim
  -- { 'monaqa/dial.nvim' },         -- enhanced increment/decrement plugin for Neovim.
  -- { 'wsdjeg/vim-fetch' },         -- enables to process line and column jump specifications
  -- { 'andrewferrier/debugprint.nvim' },
  { 'michaelb/sniprun', build = './install.sh' },
  { 'stevearc/overseer.nvim' },
  -- { 'MunifTanjim/nui.nvim' },
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

-- Define main config table to be able to use it in scripts
_G.Config = {}
