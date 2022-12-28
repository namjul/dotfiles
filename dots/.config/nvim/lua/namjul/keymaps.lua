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
  -- ['-'] = { vim.cmd.Ex, 'Open Explore' },
  ['<C-d>'] = { '<C-d>zz', 'Up' },
  ['<C-u>'] = { '<C-u>zz', 'Down' },
  n = { 'nzzzv', 'Search next' },
  N = { 'Nzzzv', 'Search Previous' },
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
  J = { 'mzJ`z', 'Join lines' },
  ['<C-L>'] = {
    ":lua require('dendron.telescope').lookup(require('telescope.themes').get_ivy({}))<CR>",
    'Lookup in Dendron',
  },
  ['<Up>'] = { ':cprev<CR>', 'Previous in quickfix list' },
  ['<Down>'] = { ':cnext<CR>', 'Next in quickfix list' },
  ['<Left>'] = { ':cpfile<CR>', 'Last Error in quickfix list' },
  ['<Right>'] = { ':cnfile<CR>', 'First Error in quickfix list' },
  ['<S-Up>'] = { ':lprev<CR>', 'Previous in location list' },
  ['<S-Down>'] = { ':lnext<CR>', 'Next in location list' },
  ['<S-Left>'] = { ':lpfile<CR>', 'Last Error in location list' },
  ['<S-Right>'] = { ':lnfile<CR>', 'First Error in location list' },
  -- p = { '<Plug>(YankyPutAfter)', 'Put yank after' },
  -- P = { '<Plug>(YankyPutBefore)', 'Put yank before' },
  -- gp = { '<Plug>(YankyGPutAfter)', 'Put yank after leaving cursor after text' },
  -- gP = { '<Plug>(YankyGPutBefore)', 'Put yank before leaving cursor after text' },
  -- ['<c-n>'] = { '<Plug>(YankyCycleForward)', 'Yank cycle forward' },
  -- ['<c-p>'] = { '<Plug>(YankyCycleBackward)', 'Yank cycle backward' },
  y = { '<Plug>(YankyYank)', 'Yank which preserves cursor position' },
  ['<c-k>'] = { ":lua require('namjul.functions.telescope').findFiles()<CR>", 'Go to File' },
  ['<c-s>'] = { '<Plug>(Switch)', 'Switch' },
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
  ['ff'] = {
    function()
      vim.lsp.buf.format({ async = true })
    end,
    'LSP format',
  },
  s = { '<Plug>(leap-forward-to)', 'Leap forward to' },
  S = { '<Plug>(leap-backward-to)', 'Leap backward to' },
  gs = { '<Plug>(leap-cross-window)', 'Leap cross window' },
  -- x = { ':!chmod +x %<CR>', "Make current file executable" },
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
  -- a = { 'ggVG', 'Select all' },
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
    ":lua require('namjul.functions.telescope').grepString()<CR>",
    'Grep word under cursor',
  },
  ['?'] = {
    ":lua require('namjul.functions.telescope').grepString({ search = vim.fn.input('Grep > ') })<CR>",
    'Grep word',
  },
  ['/'] = {
    ":lua require('namjul.functions.telescope').liveGrep()<CR>",
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
  n = { ':nohlsearch<CR>', 'Clear search highlight' },
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
  rn = {
    function()
      vim.lsp.buf.rename()
    end,
    'LSP Rename',
  },
  Y = { [["+Y]], 'Yank into clipboard' },
  y = { [["+y]], "Yank into clipboard" },
  vp = { vim.cmd.VimuxPromptCommand, "Prompt for a command to run"},
  vl = { vim.cmd.VimuxRunLastCommand, "Run last command executed by VimuxRunCommand"},
  vi = { vim.cmd.VimuxInspectRunner, "Vimux Inspect runner pane"},
  vz = { vim.cmd.VimuxZoomRunner, "Zoom the tmux runner pane"},
}, util.shallow_merge(defaultMapping, { prefix = '<leader>' }))

wk.register({
  y = { [["+y]], 'Yank into clipboard' },
}, util.shallow_merge(defaultMapping, { prefix = '<leader>', mode = 'v' }))

-- VISUAL
--------------------

wk.register({
  -- p = { '<Plug>(YankyPutAfter)', 'Put yank after' },
  -- P = { '<Plug>(YankyPutBefore)', 'Put yank before' },
  -- gp = { '<Plug>(YankyGPutAfter)', 'Put yank after leaving cursor after text' },
  -- gP = { '<Plug>(YankyGPutBefore)', 'Put yank before leaving cursor after text' },
  y = { '<Plug>(YankyYank)', 'Yank which preserves cursor position' },
  s = { '<Plug>(leap-forward-to)', 'Leap forward to' },
  S = { '<Plug>(leap-backward-to)', 'Leap backward to' },
  gs = { '<Plug>(leap-cross-window)', 'Leap cross window' },
  J = { ":m '>+1<CR>gv=gv", 'Move up' },
  K = { ":m '<-2<CR>gv=gv", 'move down' },
  p = { [["_dP]], 'Paste without overide' },
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
