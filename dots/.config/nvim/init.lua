-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    ██╗███╗   ██╗██╗████████╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    ██║████╗  ██║██║╚══██╔══╝
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    ██║██╔██╗ ██║██║   ██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    ██║██║╚██╗██║██║   ██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██║██║ ╚████║██║   ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

----------
-- Aliases
----------

local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables

----------
-- Helpers
----------

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

----------
-- Plugins
----------

cmd('packadd paq-nvim') -- load the package manager
local paq = require('paq-nvim').paq -- a convenient alias
paq {'tpope/vim-sensible'}

----------
-- Options
----------

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

----------
-- Custom Mappings
----------

-- Normal

map('n', 'Q', '') -- Avoid unintentional switches to Ex mode.
map('', 'Y', 'y$') -- Multi-mode mappings (Normal, Visual, Operating-pending modes).
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')


