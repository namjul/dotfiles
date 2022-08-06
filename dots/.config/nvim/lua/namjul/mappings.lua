local vimp = require('vimp')
local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local util = require('namjul.utils')
local map = util.map
local var = util.var

-- LEADER
--------------------

-- set Space as leader
var.g({ mapleader = ' ' })
var.b({ mapleader = ' ' })

-- map.g('n', '<leader>a', 'ggVG') -- select all (using now `:%d` or `:%y`)
map.g('n', '<leader><leader>', '<C-^>') -- open last buffer.
map.g('n', '<leader>o', ':only<CR>') -- close all windows but the active one

-- r = reload vimrc
vimp.nnoremap('<leader>r', function()
  -- Remove all previously added vimpeccable maps
  vimp.unmap_all()
  -- Unload the lua namespace so that the next time require('config.X') is called
  -- it will reload the file
  require('namjul.utils').unload_lua_namespace('namjul')
  -- Make sure all open buffers are saved
  vim.cmd('silent wa')
  -- Execute our vimrc lua file again to add back our maps
  dofile(vim.fn.stdpath('config') .. '/init.lua')

  print('Reloaded vimrc!')
end)

-- Show the path of the current file and add it to clipboard (mnemonic: path; useful when you have a lot of splits and the status line gets truncated).
vimp.nnoremap('<leader>p', function()
  local file = fn.join({ fn.expand('%'), fn.line('.') })
  cmd('let @+="' .. file .. '"')
  print(file)
end)

vimp.nnoremap('<leader>te', ':Trans en<CR>')
vimp.nnoremap('<leader>tg', ':Trans de<CR>')

if util.isVsCode() then
  vimp.nnoremap('<leader>w', ':Write<CR>') -- quick save
  vimp.nnoremap('<leader>q', ':Quit<CR>') -- quites the current window and vim if its the last
else
  vimp.nnoremap('<leader>w', ':write<CR>') -- quick save
  vimp.nnoremap('<leader>x', ':exit<CR>') -- like ":wq", but write only when changes have been
  vimp.nnoremap('<leader>q', ':quit<CR>') -- quites the current window and vim if its the last
end

map.g('n', 'gx', ':!open <cWORD><CR>')

-- guifont mappings
if util.isNeoVide() then

  -- Call function on startup to set default value
  require('namjul.functions.guifont').resetGuiFont()

  local opts = { 'silent' }
  vimp.nnoremap(opts, '<C-+>', function()
    require('namjul.functions.guifont').resizeGuiFont(1)
  end)
  vimp.nnoremap(opts, '<C-->', function()
    require('namjul.functions.guifont').resizeGuiFont(-1)
  end)
  vimp.nnoremap(opts, '<C-0>', function()
    require('namjul.functions.guifont').resetGuiFont()
  end)
end

-- telescrope mappings
map.g(
  'n',
  '<leader>*',
  ":lua require('telescope.builtin').grep_string(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search for word under cursor
map.g(
  'n',
  '<leader>/',
  ":lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search for word
map.g('n', '<leader>f', ":lua require('namjul.functions.telescope').findFiles()<CR>", { silent = true }) -- search for word under cursor
-- map.g(
--   'n',
--   '<leader>f',
--   ":lua require('telescope').extensions.fzf_writer.files(require('telescope.themes').get_ivy({}))<CR>",
--   { silent = true }
-- ) -- search for word under cursor
-- map.g(
--   'n',
--   '<leader>/',
--   ":lua require('telescope').extensions.fzf_writer.staged_grep(require('telescope.themes').get_ivy({}))<CR>",
--   { silent = true }
-- ) -- search for word under cursor
map.g(
  'n',
  '<leader>b',
  ":lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search buffers
map.g(
  'n',
  '<leader>c',
  ":lua require('telescope.builtin').commands(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
) -- search commands

-- open new splits in a semantic way
-- map.g('n', '<leader><C-h>', ':lefta vs new<CR>')
-- map.g('n', '<leader><C-j>', ':below sp new<CR>')
-- map.g('n', '<leader><C-k>', ':above sp new<CR>')
-- map.g('n', '<leader><C-l>', ':rightb vsp new<CR>')

map.g('n', '<leader>2', ':w<CR>:! ./%<CR>') -- execute current file

vimp.nnoremap('<leader>y', require('namjul.functions.telescope').searchDotfiles)

map.g('n', '<leader>gb', ":lua require('telescope.builtin').git_branches()<CR>")

-- map.g('n', '<leader>d', 'v:lua.openDailyJN("note")', { expr = true })
-- map.g('n', '<leader>j', 'v:lua.openDailyJN("journal")', { expr = true })

map.g('', 'Y', 'y$') -- multi-mode mappings (Normal, Visual, Operating-pending modes).

-- moving text
-- map.g('v', 'J', ":m '>+1<CR>gv=gv")
-- map.g('v', 'K', ":m '<-2<CR>gv=gv")
-- map.g('i', '<C-j>', '<esc>:m .+1<CR>==')
-- map.g('i', '<C-k>', '<esc>:m .-2<CR>==')
map.g('n', 'K', ':m .-2<CR>==')
map.g('n', 'J', ':m .+1<CR>==')

-- PLUGIN:dendron
map.g(
  'n',
  '<leader>d',
  ":lua require('namjul.dendron._telescope').lookup(require('telescope.themes').get_ivy({}))<CR>",
  { silent = true }
)
map.g('n', '<leader><C-i>', ":lua require('namjul.dendron').openDailyNote()<CR>", { silent = true })
map.g('n', '<leader><C-l>', ':NV<CR>', { silent = true })

-- PLUGIN:goyo.vim
map.g('n', '<leader>z', ':ZenMode<CR>', { silent = true })

-- PLUGIN:vim-maximizer
map.g('n', '<leader>m', ':MaximizerToggle<CR>', { silent = true })

-- PLUGIN:harpoon
map.g('n', '<leader>a', ':lua require("harpoon.mark").add_file()<CR>', { silent = true })
map.g('n', '<leader>s', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', { silent = true })
map.g('n', '<leader>j', ':lua require("harpoon.ui").nav_file(1)<CR>', { silent = true })
map.g('n', '<leader>k', ':lua require("harpoon.ui").nav_file(2)<CR>', { silent = true })
map.g('n', '<leader>l', ':lua require("harpoon.ui").nav_file(3)<CR>', { silent = true })
map.g('n', '<leader>ö', ':lua require("harpoon.ui").nav_file(4)<CR>', { silent = true })

-- NORMAL
--------------------

map.g('n', 'Q', '') -- avoid unintentional switches to Ex mode.

-- move between windows.
-- map.g('n', '<C-h>', '<C-w>h')
-- map.g('n', '<C-j>', '<C-w>j')
-- map.g('n', '<C-k>', '<C-w>k')
-- map.g('n', '<C-l>', '<C-w>l')

-- store relative line number jumps in the jumplist if they exceed a threshold.
map.g('n', 'k', '(v:count > 5 ? "m\\\'" . v:count : "") . "k"', { expr = true })
map.g('n', 'j', '(v:count > 5 ? "m\\\'" . v:count : "") . "j"', { expr = true })

-- repurpose cursor keys (accessible near homerow via "SpaceFN" layout) for one
-- of my most oft-use key sequences.
map.g('n', '<Up>', ':cprevious<CR>', { silent = true })
map.g('n', '<Down>', ':cnext<CR>', { silent = true })
map.g('n', '<Left>', ':cpfile<CR>', { silent = true })
map.g('n', '<Right>', ':cnfile<CR>', { silent = true })

map.g('n', '<S-Up>', ':lprevious<CR>', { silent = true })
map.g('n', '<S-Down>', ':lnext<CR>', { silent = true })
map.g('n', '<S-Left>', ':lpfile<CR>', { silent = true })
map.g('n', '<S-Right>', ':lnfile<CR>', { silent = true })

-- VISUAL
--------------------

-- move between windows.
-- map.g('x', '<C-h>', '<C-w>h')
-- map.g('x', '<C-j>', '<C-w>j')
-- map.g('x', '<C-k>', '<C-w>k')
-- map.g('x', '<C-l>', '<C-w>l')

-- COMMAND
--------------------

map.g('c', '<C-a>', '<Home>')
map.g('c', '<C-e>', '<End>')

-- INSERT
--------------------

map.g('i', 'jk', '<Esc>', { noremap = false }) -- esc mapping
map.g('i', '<Bar>', '<Bar><Esc>:call v:lua.alignMdTable() <CR>a', { silent = true }) -- align markdown table

-- Undo break points
map.g('i', ',', ',<C-g>u')
map.g('i', '.', '.<C-g>u')
map.g('i', '!', '!<C-g>u')
map.g('i', '?', '?<C-g>u')

-- TERMINAL
--------------------

map.g('t', '<Esc>', 'v:lua.terminalEsc()', { expr = true })
