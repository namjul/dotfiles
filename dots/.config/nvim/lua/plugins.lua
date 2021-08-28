return require('packer').startup(function(use)
  use('wbthomason/packer.nvim') -- Packer can manage itself
  use('svermeulen/vimpeccable') -- Neovim plugin that allows you to easily map keys directly to lua code inside your init.lua
  use('tpope/vim-sensible') -- sensible defaults
  use('wincent/pinnacle') -- Required for namjul.statusline. Highlight group manipulation utils
  use('tpope/vim-sensible') -- sensible defaults
  use('tpope/vim-repeat') -- enables the repeat command to work with external plugins
  use('tpope/vim-fugitive') -- git integration
  use('rbong/vim-flog') -- git branch viewer
  use('tpope/vim-rhubarb') -- open files on github
  use('tpope/vim-surround') -- adds operators for surrounding characters
  use('tpope/vim-unimpaired') -- set of complementary pair commands
  use('tomtom/tcomment_vim') -- Temporarily commenting
  use('svermeulen/vim-cutlass') -- seperate `cut` form `delete`
  use('svermeulen/vim-subversive') -- adds a subsitute operator
  use('svermeulen/vim-yoink') -- adds easy access to history of yanks
  use('wincent/loupe') -- enhancements to vim's search commands
  use('wincent/scalpel') -- helper for search and replace
  use('editorconfig/editorconfig-vim') -- support editor config files (https://editorconfig.org/)

  use('nvim-lua/plenary.nvim')
  use('nvim-telescope/telescope.nvim')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })
  -- 'nvim-telescope/telescope-fzf-writer.nvim',

  use('junegunn/goyo.vim') -- zen mode for writing
  -- use('Yggdroot/indentLine') -- makes space indented code visible
  -- use({ 'lukas-reineke/indent-blankline.nvim', branch = 'lua' }) --
  use({ 'junegunn/fzf', run = vim.fn['fzf#install'] }) -- requirement for 'alok/notational-fzf-vim'. fuzzy search
  use('alok/notational-fzf-vim') -- combines the fzf with the concept from notational
  use('benmills/vimux') -- allows to send commands from vim to tmux
  use('tyewang/vimux-jest-test') -- simplifies running jest test from vim
  use('justinmk/vim-dirvish') -- file explorer
  use('jeffkreeftmeijer/vim-numbertoggle') -- improves the display of line numbers
  use('jiangmiao/auto-pairs') -- auto closes pairs
  use('Valloric/MatchTagAlways') -- highlights xml tags enclosing the cursor
  use('simeji/winresizer') -- helper for resizing windows
  use('camspiers/lens.vim') -- auto resizing of windows
  use('windwp/nvim-ts-autotag') -- auto closes xml tags
  -- use('morhetz/gruvbox')
  -- use('chriskempson/base16-vim')
  -- use('icymind/NeoSolarized')
  -- use('arcticicestudio/nord-vim')
  -- use('mhartington/oceanic-next')
  -- use('srcery-colors/srcery-vim')
  -- use('sonph/onehalf', { 'rtp': 'vim/' })
  -- use('drewtempelmeyer/palenight.vim')
  -- use('ayu-theme/ayu-vim')
  -- use('rakr/vim-one')
  use('lewis6991/gitsigns.nvim')
  use('rhysd/committia.vim') -- improves vim 'commit' buffer
  use('sheerun/vim-polyglot') -- general language support
  use('moll/vim-node') -- improves dx in node.js env
  use('SirVer/ultisnips') -- snippets engine
  use('honza/vim-snippets') -- general snippets collection
  use('mattn/gist-vim') -- interact with github gist from vim
  use('mattn/webapi-vim') -- needed for `gist-vim`
  use('dense-analysis/ale') -- linter, fixer and lsp
  use({
    'Shougo/deoplete.nvim',
    run = ':UpdateRemotePlugins',
  }) -- autocomplete
  use('norcalli/nvim-colorizer.lua') -- The fastest Neovim colorizer.
  use('machakann/vim-highlightedyank') -- highlights yanked text
  use('dkarter/bullets.vim') -- enhance bullet points management
  use('csexton/trailertrash.vim') -- highlight trailing whitespace
  use('kassio/neoterm') -- simple terminal access
  use('godlygeek/tabular') -- auto alignment
  use({ 'namjul/vim-markdown', branch = 'wikilinks' }) -- own fork of that adds wikilinks support
  use('tpope/vim-obsession') -- helper to start vim sessions
  use({
    'npxbr/glow.nvim',
    run = ':GlowInstall',
    branch = 'main',
  }) -- markdown preview
  use({
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  })
  use('rktjmp/lush.nvim') -- Required for 'npxbr/gruvbox.nvim' - Define Neovim themes as a DSL in lua, with real-time feedback.
  use('npxbr/gruvbox.nvim')
  use('rafcamlet/nvim-luapad')
end)
