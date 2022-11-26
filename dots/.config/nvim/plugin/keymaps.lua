local has_which_key = pcall(require, 'which-key')

if not has_which_key then
  return
end

local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local util = require('namjul.utils')
local map = util.map
local var = util.var
local wk = require('which-key')

wk.setup({
  ignore_missing = false,
})

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
  ['<C-L>'] = {
    ":lua require('dendron._telescope').lookup(require('telescope.themes').get_ivy({}))<CR>",
    'Lookup in Dendron',
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
  p = { '<Plug>(YankyPutAfter)', 'Put yank after' },
  P = { '<Plug>(YankyPutBefore)', 'Put yank before' },
  gp = { '<Plug>(YankyGPutAfter)', 'Put yank after leaving cursor after text' },
  gP = { '<Plug>(YankyGPutBefore)', 'Put yank before leaving cursor after text' },
  ['<c-n>'] = { '<Plug>(YankyCycleForward)', 'Yank cycle forward' },
  ['<c-p>'] = { '<Plug>(YankyCycleBackward)', 'Yank cycle backward' },
  ['<c-k>'] = { ":lua require('namjul.functions.telescope').findFiles()<CR>", 'Go to File' },
  ['<c-s>'] = { '<Plug>(Switch)', 'Switch' },
  y = { '<Plug>(YankyYank)', 'Yank which preserves cursor position' },
  gr = {
    ':Trouble lsp_references<CR>',
    'LSP References',
  },
  ['[d'] = {
    function()
      vim.diagnostic.goto_prev({ enable_popup = false })
    end,
    'LSP Diagnostic Previous',
  },
  [']d'] = {
    function()
      vim.diagnostic.goto_next({ enable_popup = false })
    end,
    'LSP Diagnostic Next',
  },
  ['gd'] = {
    function()
      vim.lsp.buf.definition()
    end,
    'LSp Definition',
  },
  ['K'] = {
    function()
      if ({ vim = true, lua = true, help = true })[vim.bo.filetype] then
        vim.fn.execute('h ' .. vim.fn.expand('<cword>'))
      end
      vim.lsp.buf.hover()
    end,
    'LSP Hover or Vim K',
  },
  ['<leader>rn'] = {
    function()
      vim.lsp.buf.rename()
    end,
    'LSP Rename',
  },

  ['ff'] = {
    function()
      vim.lsp.buf.format({ async = true })
    end,
    'LSP format',
  },
  s = { '<Plug>(leap-forward-to)', 'Leap forward to' },
  S = { '<Plug>(leap-backward-to)', 'Leap backward to' },
  gs = { '<Plug>(leap-cross-window)', 'Leap cross window' },
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

-- LEADER
--------------------

wk.register({
  ['<leader>'] = { '<C-^>', 'Open last buffer' },
  -- disabled (using now `:%d` or `:%y`) a = { "ggVG", 'select all' }
  o = { ':only<CR>', 'Close all windows but active one' },
  r = {
    function()
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
  f = {
    name = 'find',
    r = { ":lua require('namjul.functions.telescope').findRecent()<CR>", 'Find Recent Files' },
    c = { ":lua require('namjul.functions.telescope').findMostWanted()<CR>", 'Find Most Wanted Folders' },
    b = {
      ":lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy({}))<CR>",
      'Find Buffer',
    },
    d = { require('namjul.functions.telescope').searchDotfiles, 'Search dotfiles' },
    g = {
      b = { ":lua require('telescope.builtin').git_branches()<CR>", 'Find branch' },
      c = { ":lua require('telescope.builtin').git_commits()<CR>", 'Find buffer commits' },
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
  ['1'] = { ':RooterToggle<CR>', 'Execute current file', silent = false },
  ['2'] = { ':w<CR>:! ./%<CR>', 'Execute current file' },
  -- PLUGIN:dendron
  ['<C-i>'] = { ":lua require('dendron').openDailyNote()<CR>", 'Create Daily Note' },
  z = { ':ZenMode<CR>', 'Enter Zenmode' },
  m = { ':MaximizerToggle<CR>', 'Maximize window' },
  n = { '<Plug>(LoupeClearHighlight)', 'Clear search highlight' },
  e = { '<Plug>(Scalpel)', 'Replace word' },
  -- PLUGIN:harpoon
  ba = { ':lua require("harpoon.mark").add_file()<CR>', 'Add file to harpoon' },
  bl = { ':lua require("harpoon.ui").toggle_quick_menu()<CR>', 'Toggle harpoon menu' },
  j = { ':lua require("harpoon.ui").nav_file(1)<CR>', 'Harpoon: Goto(1)' },
  k = { ':lua require("harpoon.ui").nav_file(2)<CR>', 'Harpoon: Goto(2)' },
  l = { ':lua require("harpoon.ui").nav_file(3)<CR>', 'Harpoon: Goto(3)' },
  ['ö'] = { ':lua require("harpoon.ui").nav_file(4)<CR>', 'Harpoon: Goto(4)' },
  dp = {
    function()
      return require('debugprint').debugprint()
    end,
    'DebugPrint',
    expr = true,
  },
  dv = {
    function()
      return require('debugprint').debugprint({ variable = true })
    end,
    'DebugPrint',
    expr = true,
  },
  s = { '<Plug>(SubversiveSubstitute)', 'Substitute' },
  ss = { '<Plug>(SubversiveSubstituteLine)', 'Substitute line' },
  S = { '<Plug>(SubversiveSubstituteToEndOfLine)', 'Substitute End of line' },
}, util.shallow_merge(defaultMapping, { prefix = '<leader>' }))

-- VISUAL
--------------------

wk.register({
  pp = { '<Plug>(YankyPutAfter)', 'Put yank after' },
  P = { '<Plug>(YankyPutBefore)', 'Put yank before' },
  gp = { '<Plug>(YankyGPutAfter)', 'Put yank after leaving cursor after text' },
  gP = { '<Plug>(YankyGPutBefore)', 'Put yank before leaving cursor after text' },
  y = { '<Plug>(YankyYank)', 'Yank which preserves cursor position' },
  s = { '<Plug>(leap-forward-to)', 'Leap forward to' },
  S = { '<Plug>(leap-backward-to)', 'Leap backward to' },
  gs = { '<Plug>(leap-cross-window)', 'Leap cross window' },
}, util.shallow_merge(defaultMapping, { mode = 'x' }))

-- OPERATOR PENDING
--------------------

wk.register({
  s = { '<Plug>(leap-forward-to)', 'Leap forward to' },
  S = { '<Plug>(leap-backward-to)', 'Leap backward to' },
  gs = { '<Plug>(leap-cross-window)', 'Leap cross window' },
}, util.shallow_merge(defaultMapping, { mode = 'o' }))

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
