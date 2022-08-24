local has_which_key = pcall(require, 'which-key')
local has_vimp = pcall(require, 'vimp')

if not has_which_key or not has_vimp then
  return
end


local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local util = require('namjul.utils')
local map = util.map
local var = util.var
local wk = require('which-key')
local vimp = require('vimp')

wk.setup {
  ignore_missing = false
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}


-- LEADER
--------------------

-- set Space as leader
var.g({ mapleader = ' ' })
var.b({ mapleader = ' ' })

map.g('', 'Y', 'y$') -- multi-mode mappings (Normal, Visual, Operating-pending modes).

-- moving text
-- map.g('v', 'J', ":m '>+1<CR>gv=gv")
-- map.g('v', 'K', ":m '<-2<CR>gv=gv")
-- map.g('i', '<C-j>', '<esc>:m .+1<CR>==')
-- map.g('i', '<C-k>', '<esc>:m .-2<CR>==')
-- map.g('n', 'K', ':m .-2<CR>==')
-- map.g('n', 'J', ':m .+1<CR>==')

-- NORMAL
--------------------

local defaultMapping = {
  mode = 'n',
  prefix = '',
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = false,
}

wk.register({
  Q = { '', 'avoid unintentional switches to Ex mode.' },
  gx = { ':!open <cWORD><CR>', 'open url' },
  -- ['<C-h>'] = { '<C-w>h', 'Focus window on the left' },
  -- ['<C-j>'] = { '<C-w>j', 'Focus window on the bottom' },
  -- ['<C-k>'] = { '<C-w>k', 'Focus window on the top' },
  -- ['<C-l>'] = { '<C-w>l' , 'Focus window on the right'},
  k = {
    '(v:count > 5 ? "m\\\'" . v:count : "") . "k"',
    'store relative line number jumps in the jumplist if they exceed a threshold.',
    expr = true,
  },
  j = {
    '(v:count > 5 ? "m\\\'" . v:count : "") . "j"',
    'store relative line number jumps in the jumplist if they exceed a threshold.',
    expr = true,
  },
  -- repurpose cursor keys (accessible near homerow via "SpaceFN" layout) for one of my most oft-use key sequences.
  ['<Up>'] = { ':cprevious<CR>', 'Previous in quickfix list' },
  ['<Down>'] = { ':cnext<CR>', 'Next in quickfix list' },
  ['<Left>'] = { ':cpfile<CR>', 'Last Error in quickfix list' },
  ['<Right>'] = { ':cnfile<CR>', 'First Error in quickfix list' },
  ['<S-Up>'] = { ':lprevious<CR>', 'Previous in location list' },
  ['<S-Down>'] = { ':lnext<CR>', 'Next in location list' },
  ['<S-Left>'] = { ':lpfile<CR>', 'Last Error in location list' },
  ['<S-Right>'] = { ':lnfile<CR>', 'First Error in location list' },
}, defaultMapping)

-- guifont mappings
if util.isNeoVide() then
  local guifont = require('namjul.functions.guifont')
  guifont.resetGuiFont() -- Call function on startup to set default value
  wk.register({
    ['<C-+>'] = {
      function()
        guifont.resizeGuiFont(1)
      end,
      'Increase fontsize',
    },
    ['<C-->'] = {
      function()
        guifont.resizeGuiFont(-1)
      end,
      'Increase fontsize',
    },
    ['<C-0>'] = {
      function()
        guifont.resetGuiFont()
      end,
      'Increase fontsize',
    },
  }, defaultMapping)
end

wk.register({
  ['<leader>'] = { '<C-^>', 'Open last buffer' },
  -- disabled (using now `:%d` or `:%y`) a = { "ggVG", 'select all' }
  o = { ':only<CR>', 'Close all windows but active one' },
  r = {
    function()
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
    end,
    'Reload vimrc',
  },
  p = {
    function()
      local file = fn.join({ fn.expand('%'), fn.line('.'), fn.col('.') }, ':')
      cmd('let @+="' .. file .. '"')
      print(file)
    end,
    'Show the path of the current file and add it to clipboard (mnemonic: path; useful when you have a lot of splits and the status line gets truncated).',
  },
  t = {
    name = 'Translator',
    e = { ':Trans en <CR>', 'Translate to English(word under cursor)' },
    g = { ':Trans de <CR>', 'Translate to German(word under cursor)' },
  },
  w = {
    util.isVsCode() and ':Write<CR>' or ':write<CR>',
    'Quick save',
  },
  q = {
    util.isVsCode() and ':Quit<CR>' or ':quit<CR>',
    'Quites the current window and vim if its the last',
  },
  x = {
    ':exit<CR>',
    'like ":wq", but write only when changes have been made',
  },
  ['*'] = {
    ":lua require('telescope.builtin').grep_string(require('telescope.themes').get_ivy({}))<CR>",
    'Grep word',
  },
  ['/'] = {
    ":lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy({}))<CR>",
    'Search word',
  },
  -- f = { ":lua require('namjul.functions.telescope').findFiles()<CR>", 'Find Files' },
  f = {
    name = 'file', -- optional group name
    f = { ":lua require('namjul.functions.telescope').findFiles()<CR>", 'Find Files' },
    r = { ":lua require('namjul.functions.telescope').findRecent()<CR>", 'Find Recent Files' },
    c = { ":lua require('namjul.functions.telescope').findMostWanted()<CR>", 'Find Most Wanted Files' },
    b = {
      ":lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy({}))<CR>",
      'Find Buffer',
    },
    d = { require('namjul.functions.telescope').searchDotfiles, 'Search dotfiles' },
    g = {
      b = { ":lua require('telescope.builtin').git_branches()<CR>", 'Find branch' },
    },
    l = {
      ":lua require('dendron._telescope').lookup(require('telescope.themes').get_ivy({}))<CR>",
      'Lookup in Dendron',
    },
    y = { ':NV<CR>', 'Search in Dendron' },
  },
  c = {
    ":lua require('telescope.builtin').commands(require('telescope.themes').get_ivy({}))<CR>",
    'Find Command',
  },
  -- open new splits in a semantic way
  -- ['<C-h>'] = { ':lefta vs new<CR>', 'Open new file to the left' },
  -- ['<C-j>'] = { ':below sp new<CR>', 'Open new file below' },
  -- ['<C-k>'] = { ':above sp new<CR>', 'Open new file above' },
  -- ['<C-l>'] = { ':rightb vsp new<CR>', 'Open new file to the right' },
  ['2'] = { ':w<CR>:! ./%<CR>', 'Execute current file' },
  -- PLUGIN:dendron
  ['<C-i>'] = { ":lua require('dendron').openDailyNote()<CR>", 'Create Daily Note' },
  z = { ':ZenMode<CR>', 'Enter Zenmode' },
  m = { ':MaximizerToggle<CR>', 'Maximize window' },
  -- PLUGIN:harpoon
  a = { ':lua require("harpoon.mark").add_file()<CR>', 'Add file to harpoon' },
  s = { ':lua require("harpoon.ui").toggle_quick_menu()<CR>', 'Toggle harpoon menu' },
  j = { ':lua require("harpoon.ui").nav_file(1)<CR>', 'Harpoon: Goto(1)' },
  k = { ':lua require("harpoon.ui").nav_file(2)<CR>', 'Harpoon: Goto(2)' },
  l = { ':lua require("harpoon.ui").nav_file(3)<CR>', 'Harpoon: Goto(3)' },
  ['ö'] = { ':lua require("harpoon.ui").nav_file(4)<CR>', 'Harpoon: Goto(4)' },
}, util.shallow_merge(defaultMapping, { prefix = '<leader>' }))

-- VISUAL
--------------------

-- COMMAND
--------------------

-- currently not working https://github.com/folke/which-key.nvim/issues/312
-- wk.register({
--   ['<C-a'] = { '<Home>' },
--   ['<C-e'] = { '<End>' },
-- }, util.shallow_merge(defaultMapping, { mode = 'c', noremap = true }))

map.g('c', '<C-a>', '<Home>')
map.g('c', '<C-e>', '<End>')

-- INSERT
--------------------

wk.register({
  ['jk'] = { '<Esc>', 'Esc Mapping' },
  ['<Bar>'] = { '<Bar><Esc>:call v:lua.alignMdTable() <CR>a', 'Align markdonw table' },
  -- jk = { '<Esc>', 'Escape mapping',  { noremap = false } },
  -- Undo break points
  [','] = { ',<C-g>u' },
  ['.'] = { '.<C-g>u' },
  ['!'] = { '!<C-g>u' },
  ['?'] = { '?<C-g>u' },
}, util.shallow_merge(defaultMapping, { mode = 'i' }))

-- TERMINAL
--------------------

wk.register({
  ['<Esc>'] = {
    util.termcodes('<C-\\><C-N>'),
    'Close terminal',
  },
}, { prefix = '', mode = 't', noremap = true, silent = true })
