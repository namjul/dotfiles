-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

--------------------
-- Aliases
--------------------

local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables

--------------------
-- Helpers
--------------------

local scopes = {g = vim.o, b = vim.bo, w = vim.wo}
local function opt(scope, key, value) -- simulates VimScript `set` function
  scopes[scope][key] = value
  if scope ~= 'g' then
    scopes['g'][key] = value
  end
end

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true } -- default to non-recursive map
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- The function is called `t` for `termcodes`.
local function t(str)
    -- Adjust boolean arguments as needed
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

--------------------
-- Plugins
--------------------

cmd('packadd paq-nvim') -- load the package manager
local paq = require('paq-nvim').paq -- a convenient alias

paq('tpope/vim-sensible')
paq('tpope/vim-sensible') -- sensible defaults
paq('tpope/vim-repeat') -- enables the repeat command to work with external plugins
paq('tpope/vim-fugitive') -- git integration
paq('rbong/vim-flog') -- git branch viewer
paq('tpope/vim-rhubarb') -- open files on github
paq('tpope/vim-surround') -- adds operators for surrounding characters
paq('tpope/vim-unimpaired') -- set of complementary pair commands
paq('tpope/vim-commentary') -- Temporarily commenting
paq('svermeulen/vim-cutlass') -- seperate `cut` form `delete`
paq('svermeulen/vim-subversive') -- adds a subsitute operator
paq('svermeulen/vim-yoink') -- adds easy access to history of yanks
paq('wincent/loupe') -- enhancements to vim's search commands
paq('wincent/scalpel') -- helper for search and replace
paq('itchyny/lightline.vim') -- better statusbar
paq('editorconfig/editorconfig-vim') -- support editor config files (https://editorconfig.org/)
paq('tmux-plugins/vim-tmux-focus-events') -- makes `FocusGained` and `FocusLost` work in terminal vim, `autoread` options then works as expected
paq({'junegunn/fzf', hook=vim.fn['fzf#install'] }) -- fuzzy search
paq('junegunn/goyo.vim') -- zen mode for writing
paq('Yggdroot/indentLine') -- makes space indented code visible
paq('lukas-reineke/indent-blankline.nvim') --
paq('alok/notational-fzf-vim') -- combines the fzf with the concept from notational
paq('benmills/vimux') -- allows to send commands from vim to tmux
paq('tyewang/vimux-jest-test') -- simplifies running jest test from vim
paq('justinmk/vim-dirvish') -- file explorer
paq('jeffkreeftmeijer/vim-numbertoggle') -- improves the display of line numbers
paq('jiangmiao/auto-pairs') -- auto closes pairs
paq('Valloric/MatchTagAlways') -- highlights xml tags enclosing the cursor
paq('simeji/winresizer') -- helper for resizing windows
paq('camspiers/lens.vim') -- auto resizing of windows
paq('alvan/vim-closetag') -- auto closes the xml tag
paq('morhetz/gruvbox') -- colorscheme
-- paq('chriskempson/base16-vim')
-- paq('icymind/NeoSolarized')
-- paq('arcticicestudio/nord-vim')
-- paq('mhartington/oceanic-next')
-- paq('srcery-colors/srcery-vim')
-- paq('sonph/onehalf', { 'rtp': 'vim/' })
-- paq('drewtempelmeyer/palenight.vim')
-- paq('ayu-theme/ayu-vim')
-- paq('rakr/vim-one')
paq('airblade/vim-gitgutter') --- add info to sidebar about git
paq('rhysd/committia.vim') -- improves vim 'commit' buffer
paq('sheerun/vim-polyglot') -- general language support
paq('moll/vim-node') -- improves dx in node.js env
paq('SirVer/ultisnips') -- snippets engine
paq('honza/vim-snippets') -- general snippets collection
paq('mattn/gist-vim') -- interact with github gist from vim
paq('mattn/webapi-vim') -- needed for `gist-vim`
paq('dense-analysis/ale') -- linter, fixer and lsp
paq({ 'Shougo/deoplete.nvim',  hook=function () cmd('UpdateRemotePlugins') end }) -- autocomplete
paq('ap/vim-css-color') -- color name highlighter
paq('machakann/vim-highlightedyank') -- highlights yanked text
paq('dkarter/bullets.vim') -- enhance bullet points management
paq('csexton/trailertrash.vim') -- highlight trailing whitespace

--------------------
-- Options
--------------------

-- Global
opt('g', 'mouse', 'a') -- Enable Mouse clicking
opt('g', 'shortmess', 'I') -- Don’t show the intro message when starting Vim
opt('g', 'visualbell', true) --  Use visual bell instead of audible bell
opt('g', 'backupcopy', 'yes') -- optimize webpack watch option
opt('g', 'clipboard', 'unnamedplus')
opt('g', 'ignorecase', true)
opt('g', 'smartcase', true)
opt('g', 'wildignorecase', true)
opt('g', 'hidden', true)
opt('g', 'termguicolors', true) -- Enable term 24 bit colour
opt('g', 'gdefault', true) -- Add the g flag to search/replace by default
opt('g', 'background', 'dark')

-- Window
opt('w', 'number', true) -- Show relative lines numbers
opt('w', 'cursorline', true) -- Highlight current line
opt('w', 'wrap', false) -- don't wrap lines
opt('w', 'conceallevel', 2) -- hide concealed text

-- Buffer
opt('b', 'tabstop', 2) -- Make tabs as wide as two spaces
opt('b', 'shiftwidth', 2) -- The # of spaces for indenting.
opt('b', 'expandtab', true) -- use spaces, not tabs (optional)

--------------------
-- Custom Mappings
--------------------

map('', 'Y', 'y$') -- multi-mode mappings (Normal, Visual, Operating-pending modes).

-- NORMAL

map('n', 'Q', '') -- avoid unintentional switches to Ex mode.

-- move between windows.
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- store relative line number jumps in the jumplist if they exceed a threshold.
map('n', 'k', '(v:count > 5 ? "m\\\'" . v:count : "") . "k"', { expr=true })
map('n', 'j', '(v:count > 5 ? "m\\\'" . v:count : "") . "j"', { expr=true })


-- repurpose cursor keys (accessible near homerow via "SpaceFN" layout) for one
-- of my most oft-use key sequences.
map('n', '<Up>', ':cprevious<CR>', { silent=true })
map('n', '<Up>', ':cprevious<CR>', { silent=true })
map('n', '<Down>' , ':cnext<CR>', { silent=true })
map('n', '<Left>' , ':cpfile<CR>', { silent=true })
map('n', '<Right>' , ':cnfile<CR>', { silent=true })

map('n', '<S-Up>' , ':lprevious<CR>', { silent=true })
map('n', '<S-Down>' , ':lnext<CR>', { silent=true })
map('n', '<S-Left>' , ':lpfile<CR>', { silent=true })
map('n', '<S-Right>' , ':lnfile<CR>', { silent=true })

-- VISUAL

-- move between windows.
map('x', '<C-h>', '<C-w>h')
map('x', '<C-j>', '<C-w>j')
map('x', '<C-k>', '<C-w>k')
map('x', '<C-l>', '<C-w>l')

-- COMMAND
----------

map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')

-- INSERT

-- esc mapping
map('i', 'jk', '<Esc>', { noremap=false })
map('i', '<C-K>', '<Esc>', { noremap=false })
map('i', '<C-c>', '<Esc>')

-- TERMINAL

function _G.terminal_esc()
    return vim.bo.filetype == 'fzf' and t('<Esc>') or t('<C-\\><C-n>')
end
map('t', '<Esc>', 'v:lua.terminal_esc()', { expr = true })

-- LEADER

-- set Space as leader
vim.g.mapleader = ' '
vim.b.mapleader = ' '

map('n', '<Leader><Leader>', '<C-^>') -- open last buffer.
map('n', '<Leader>o', ':only<CR>') -- close all windows but the active one
map('n', '<Leader>p', ':echo expand("%")<CR>') -- <Leader>p - Show the path of the current file (mnemonic: path; useful when you have a lot of splits and the status line gets truncated).
map('n', '<Leader>a', 'ggVG') -- select all
map('n', '<Leader>r', ':luafile $MYVIMRC<CR>') -- auto reload of vimrc TODO test in production env.

map('n', '<Leader>w', ':write<CR>') -- quick save
map('n', '<Leader>x', ':exit<CR>') -- like ":wq", but write only when changes have been
map('n', '<Leader>q', ':quit<CR>') -- quites the current window and vim if its the last

-- fzf mappings
map('n', '<Leader>*', ':Rg <C-R><C-W><CR>', { silent=true }) -- search for word under cursor
map('n', '<Leader>/', ':Rg<space>') -- search for word
map('n', '<Leader>f', ':Files<CR>', { silent=true }) -- search for file
map('n', '<Leader>b', ':Buffers<CR>', { silent=true }) -- search buffers
map('n', '<Leader>z', ':History<CR>', { silent=true }) -- search history - TODO clashes with GitGutter
map('n', '<Leader>c', ':Commands<CR>', { silent=true }) -- search commands

-- open new splits in a semantic way
map('n', '<Leader><C-h>', ':lefta vs new<CR>')
map('n', '<Leader><C-j>', ':below sp new<CR>')
map('n', '<Leader><C-k>', ':above sp new<CR>')
map('n', '<Leader><C-l>', ':rightb vsp new<CR>')

map('n', '<Leader>2', ':w<CR>:! ./%<CR>') -- execute current file
