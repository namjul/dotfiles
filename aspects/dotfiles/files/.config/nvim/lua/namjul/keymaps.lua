local has_which_key = pcall(require, 'which-key')
local has_mini_keymap, mini_keymap = pcall(require, 'mini.keymap')
local has_mini_move, mini_move = pcall(require, 'mini.move')

if not has_which_key then
  return
end

local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn   -- to call Vim functions e.g. fn.bufnr()
local util = require('namjul.utils')
local map = util.map
local var = util.var
local wk = require('which-key')
local harpoon = require('harpoon')

if has_mini_move then
  mini_move.setup({
    mappings = {
      left = '<S-h>',
      right = '<S-l>',
      down = '<S-j>',
      up = '<S-k>',
    }
  })
end

if has_mini_keymap then
  mini_keymap.setup()

  local map_multistep = mini_keymap.map_multistep
  map_multistep('i', '<Tab>', { 'jump_after_close' })
  map_multistep('i', '<S-Tab>', { 'jump_before_open' })
  map_multistep('i', '<CR>', { 'minipairs_cr' })
  map_multistep('i', '<BS>', { 'hungry_bs', 'minipairs_bs' })

  local map_combo = mini_keymap.map_combo
  local mode = { 'i', 'c', 'x', 's' }
  local opts = { delay = 1000 }
  map_combo(mode, 'jk', '<BS><BS><Esc>', opts)

  -- To not have to worry about the order of keys, also map "kj"
  map_combo(mode, 'kj', '<BS><BS><Esc>')

  -- Escape into Normal mode from Terminal mode
  map_combo('t', 'jk', '<BS><BS><C-\\><C-n>')
  map_combo('t', 'kj', '<BS><BS><C-\\><C-n>')

  -- Easier navigation
  map_combo({ 'n', 'x' }, 'll', 'g$', { delay = 150 })
  map_combo({ 'n', 'x' }, 'hh', 'g^', { delay = 150 })
  map_combo({ 'n', 'x' }, 'jj', '}', { delay = 150 })
  map_combo({ 'n', 'x' }, 'kk', '{',{ delay = 150 })
end

-- LEADER
--------------------

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

map.g('', 'Y', 'y$') -- multi-mode mappings (Normal, Visual, Operating-pending modes).

-- moving text
-- map.g('i', '<C-j>', '<esc>:m .+1<CR>==')
-- map.g('i', '<C-k>', '<esc>:m .-2<CR>==')
-- map.g('n', 'K', ':m .-2<CR>==')
-- map.g('n', 'J', ':m .+1<CR>==')

-- NORMAL
--------------------

wk.add({
  { "-",         "<CMD>Oil<CR>",                                                    desc = "Open parent directory",                                                        nowait = false, remap = false },
  { "<C-d>",     "<C-d>zz",                                                         desc = "Up",                                                                           nowait = false, remap = false },
  { "<C-u>",     "<C-u>zz",                                                         desc = "Down",                                                                         nowait = false, remap = false },
  { "<Down>",    ":cnext<CR>",                                                      desc = "Next in quickfix list",                                                        nowait = false, remap = false },
  { "<Left>",    ":cpfile<CR>",                                                     desc = "Last Error in quickfix list",                                                  nowait = false, remap = false },
  { "<Right>",   ":cnfile<CR>",                                                     desc = "First Error in quickfix list",                                                 nowait = false, remap = false },
  { "<S-Down>",  ":lnext<CR>",                                                      desc = "Next in location list",                                                        nowait = false, remap = false },
  { "<S-Left>",  ":lpfile<CR>",                                                     desc = "Last Error in location list",                                                  nowait = false, remap = false },
  { "<S-Right>", ":lnfile<CR>",                                                     desc = "First Error in location list",                                                 nowait = false, remap = false },
  { "<S-Up>",    ":lprev<CR>",                                                      desc = "Previous in location list",                                                    nowait = false, remap = false },
  { "<Up>",      ":cprev<CR>",                                                      desc = "Previous in quickfix list",                                                    nowait = false, remap = false },
  { "<c-k>",     ":lua require('namjul.functions.telescope').findFiles()<CR>",      desc = "Go to File",                                                                   nowait = false, remap = false },
  { "<c-s>",     "<Plug>(Switch)",                                                  desc = "Switch",                                                                       nowait = false, remap = false },
  { "J",         "mzJ`z",                                                           desc = "Join lines",                                                                   nowait = false, remap = false },
  { "N",         "Nzzzv",                                                           desc = "Search Previous",                                                              nowait = false, remap = false },
  { "Q",         "",                                                                desc = "avoid unintentional switches to Ex mode.",                                     nowait = false, remap = false },
  -- { "S",         "<Plug>(leap-backward-to)",                                        desc = "Leap backward to",                                                             nowait = false, remap = false },
  -- { "s",         "<Plug>(leap-forward-to)",                                         desc = "Leap forward to",                                                              nowait = false, remap = false },
  -- { "gs",        "<Plug>(leap-cross-window)",                                       desc = "Leap cross window",                                                            nowait = false, remap = false },
  { "gp",        ":lua MiniDiff.toggle_overlay()<CR>",                              desc = "Toggle git hunks preview",                                                            nowait = false, remap = false },
  { "gx",        ":!open <cWORD><CR>",                                              desc = "open url",                                                                     nowait = false, remap = false },
  { "j",         "(v:count > 5 ? \"m\\'\" . v:count : \"\") . \"j\"",               desc = "store relative line number jumps in the jumplist if they exceed a threshold.", expr = true,    nowait = false, remap = false, replace_keycodes = false },
  { "k",         "(v:count > 5 ? \"m\\'\" . v:count : \"\") . \"k\"",               desc = "store relative line number jumps in the jumplist if they exceed a threshold.", expr = true,    nowait = false, remap = false, replace_keycodes = false },
  { "n",         "nzzzv",                                                           desc = "Search next",                                                                  nowait = false, remap = false },
  { "y",         "<Plug>(YankyYank)",                                               desc = "Yank which preserves cursor position",                                         nowait = false, remap = false },
})


-- guifont mappings
if util.isNeoVide() then
  local guifont = require('namjul.functions.guifont')
  guifont.resetGuiFont() -- Call function on startup to set default value

  wk.add({
    {
      "<C-+>",
      function()
        guifont.resizeGuiFont(1)
      end,
      desc = "Increase fontsize",
      nowait = false,
      remap = false
    },
    {
      "<C-->",
      function()
        guifont.resizeGuiFont(-1)
      end,
      desc = "Decrease fontsize",
      nowait = false,
      remap = false
    },
    {
      "<C-0>",
      function()
        guifont.resetGuiFont()
      end,
      desc = "Reset fontsize",
      nowait = false,
      remap = false
    },
  })

end

-- LEADER
--------------------

wk.add(
  {
  { "<leader>*", ":lua require('namjul.functions.telescope').grep_string()<CR>", desc = "Grep word under cursor", nowait = false, remap = false },
  { "<leader>/", ":lua require('namjul.functions.telescope').search({ previewer = false })<CR>", desc = "Search word", nowait = false, remap = false },
  { "<leader>1", ":RooterToggle<CR>", desc = "Toggle Rooter", nowait = false, remap = false, silent = false },
  { "<leader>2", ":w<CR>:! ./%<CR>", desc = "Execute current file", nowait = false, remap = false },
  { "<leader>3", ":!chmod +x %<CR>", desc = "Make current file executable", nowait = false, remap = false },
  { "<leader>b", ":lua require('namjul.functions.telescope').findBuffers()<CR>", desc = "[ ] Find existing buffers", nowait = false, remap = false },
  { "<leader><leader>", "<C-^>", desc = "Open last buffer", nowait = false, remap = false },
  { "<leader>P", ":Pastify <CR>", desc = "Paste image from clipboard", nowait = false, remap = false },
  { "<leader>c", ":lua require('telescope.builtin').commands(require('telescope.themes').get_ivy({}))<CR>", desc = "Find Command", nowait = false, remap = false },
  { "<leader>dp", function() return require('debugprint').debugprint() end, desc = "DebugPrint", expr = true, nowait = false, remap = false, replace_keycodes = false },
  { "<leader>dv", function() return require('debugprint').debugprint({ variable = true }) end, desc = "DebugPrint", expr = true, nowait = false, remap = false, replace_keycodes = false },
  { "<leader>f", group = "find", nowait = false, remap = false },
  { "<leader>fb", ":lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy({}))<CR>", desc = "Find Buffer", nowait = false, remap = false },
  { "<leader>fc", ":lua require('namjul.functions.telescope').find_most_wanted()<CR>", desc = "Find Most Wanted Folders", nowait = false, remap = false },
  { "<leader>fl", ":lua require('namjul.functions.telescope').memex()<CR>",          desc = "Search in Memex",                                                                nowait = false, remap = false },
  { "<leader>fd", ":lua require('namjul.functions.telescope').search_dotfiles()<CR>", desc = "Search dotfiles", nowait = false, remap = false },
  { "<leader>fgb", ":lua require('telescope.builtin').git_branches(require('telescope.themes').get_ivy({}))<CR>", desc = "Find branch", nowait = false, remap = false },
  { "<leader>fgc", ":lua require('telescope.builtin').git_bcommits(require('telescope.themes').get_ivy({}))<CR>", desc = "Find buffer commits", nowait = false, remap = false },
  { "<leader>fh", ":lua require('telescope.builtin').help_tags(require('telescope.themes').get_ivy({}))<CR>", desc = "Find Help", nowait = false, remap = false },
  { "<leader>fr", ":lua require('namjul.functions.telescope').find_recent()<CR>", desc = "Find Recent Files", nowait = false, remap = false },
  { "<leader>gl", ":Gclog<CR>", desc = "Open Git log", nowait = false, remap = false },
  { "<leader>gbl", ":Gclog -- %<CR>", desc = "Open Buffer Git log", nowait = false, remap = false },
  { "<leader>h", group = "harpoon", nowait = false, remap = false },
  { "<leader>ha", function() harpoon:list():add() end, desc = "Add file to harpoon", nowait = false, remap = false },
  { "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Toggle harpoon menu", nowait = false, remap = false },
  { "<leader>j", function() harpoon:list():select(1) end, desc = "Harpoon: Goto(1)", nowait = false, remap = false },
  { "<leader>k", function() harpoon:list():select(2) end, desc = "Harpoon: Goto(2)", nowait = false, remap = false },
  { "<leader>l", function() harpoon:list():select(3) end, desc = "Harpoon: Goto(3)", nowait = false, remap = false },
  { "<leader>ö", function() harpoon:list():select(4) end, desc = "Harpoon: Goto(4)", nowait = false, remap = false },
  { "<leader>m", ":MaximizerToggle<CR>", desc = "Maximize window", nowait = false, remap = false },
  { "<leader>n", ":nohlsearch<CR>", desc = "Clear search highlight", nowait = false, remap = false },
  { "<leader>o", ":only<CR>", desc = "Close all windows but active one", nowait = false, remap = false },
  { "<leader>p", function()
      local file = fn.join({ fn.expand('%'), fn.line('.'), fn.col('.') }, ':')
      cmd('let @+="' .. file .. '"')
      print(file)
    end, desc = "Show the path of the current file and add it to clipboard (mnemonic: path; useful when you have a lot of splits and the status line gets truncated).", nowait = false, remap = false },
  { "<leader>q", ":quit<CR>", desc = "Quites the current window and vim if its the last", nowait = false, remap = false },
  { "<leader>R", function()
      -- Unload the lua namespace so that the next time require('config.X') is called
      -- it will reload the file
      require('namjul.utils').unload_lua_namespace('namjul')
      -- Make sure all open buffers are saved
      vim.cmd('silent wa')
      -- Execute our vimrc lua file again to add back our maps
      dofile(vim.fn.stdpath('config') .. '/init.lua')
      print('Reloaded vimrc!')
    end, desc = "Reload vimrc", nowait = false, remap = false },
  { "<leader>t", group = "Translator", nowait = false, remap = false },
  { "<leader>te", ":Trans en <CR>", desc = "Translate to English(word under cursor)", nowait = false, remap = false },
  { "<leader>tg", ":Trans de <CR>", desc = "Translate to German(word under cursor)", nowait = false, remap = false },
  { "<leader>vi", ":lua vim.cmd('VimuxInspectRunner')<CR>", desc = "Vimux Inspect runner pane", nowait = false, remap = false },
  { "<leader>vl", ":lua vim.cmd('VimuxRunLastCommand')<CR>", desc = "Run last command executed by VimuxRunCommand", nowait = false, remap = false },
  { "<leader>vp", ":lua vim.cmd('VimuxPromptCommand')<CR>", desc = "Prompt for a command to run", nowait = false, remap = false },
  { "<leader>vz", ":lua vim.cmd('VimuxZoomRunner')<CR>", desc = "Zoom the tmux runner pane", nowait = false, remap = false },
  { "<leader>x", ":exit<CR>", desc = 'like ":wq", but write only when changes have been made', nowait = false, remap = false },
  { "<leader>z", ":ZenMode<CR>", desc = "Enter Zenmode", nowait = false, remap = false },
  { "<leader>y", '"+y', desc = "Yank into clipboard", mode = "v", nowait = false, remap = false },
  { "<leader>do", ':lua MiniDiff.toggle_overlay()<CR>', desc = "Toggle hunk diff overlay", nowait = false, remap = false },
})

-- VISUAL
--------------------

wk.add({
  {
    mode = { "x" },
    -- { "S",  "<Plug>(leap-backward-to)",  desc = "Leap backward to",                     nowait = false, remap = false },
    -- { "s",  "<Plug>(leap-forward-to)",   desc = "Leap forward to",                      nowait = false, remap = false },
    -- { "gs", "<Plug>(leap-cross-window)", desc = "Leap cross window",                    nowait = false, remap = false },
    { "p",  '"_dP',                      desc = "Paste without overide",                nowait = false, remap = false },
    { "y",  "<Plug>(YankyYank)",         desc = "Yank which preserves cursor position", nowait = false, remap = false },
  },
}
)

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

wk.add(
  {
    {
      mode = { "i" },
      { "!",     "!<C-g>u",                             nowait = false,                remap = false },
      { ",",     ",<C-g>u",                             nowait = false,                remap = false },
      { ".",     ".<C-g>u",                             nowait = false,                remap = false },
      { "?",     "?<C-g>u",                             nowait = false,                remap = false },
      { "<Bar>", "<Bar><Esc>:call v:lua.namjul.functions.alignMdTable() <CR>a", desc = "Align markdown table", nowait = false, remap = false },
      -- { "jk",    "<Esc>",                                      desc = "Esc Mapping",          nowait = false, remap = false },
    },
  }
)

-- TERMINAL
--------------------

wk.add({
  { "<Esc>", "\28\14", desc = "Close terminal", mode = "t", remap = false },
})

-- LSP
--------------------

vim.api.nvim_create_autocmd('User', {
  pattern = 'LspAttached',
  desc = 'LSP actions',
  callback = function(arg)
    local bufnr = arg.data.bufnr

    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc, nowait = false, remap = false })
    end

    local telescope = require('namjul.functions.telescope')

    nmap('[d', function() vim.diagnostic.goto_prev({ enable_popup = false }) end, "Diagnostic Previous")
    nmap(']d', function() vim.diagnostic.goto_next({ enable_popup = false }) end, "Diagnostic Previous")
    nmap('ca', vim.lsp.buf.code_action, '[C]ode [A]ction') -- conflicts with <leader>c

    nmap('<leader>e', function() vim.diagnostic.open_float() end, "LSP open diagnostic")
    nmap('<leader>i', function() vim.diagnostic.setloclist() end, "LSP open locallist")

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    nmap('gd', function()
      telescope.findLspDefinitions()
    end, '[G]oto [D]efinition')
    nmap('gr', function()
      telescope.findLspReferences()
    end, '[G]oto [R]eferences')
    -- nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>a', vim.lsp.buf.code_action, 'Code [A]action')
    nmap('<leader>ds', function()
      require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_ivy({}))
    end, '[D]ocument [S]ymbols')
    nmap('<leader>ws', function()
      require('telescope.builtin').lsp_dynamic_workspace_symbols(require('telescope.themes').get_ivy({}))
    end, '[W]orkspace [S]ymbols')
    nmap('K', function()
      if ({ vim = true, lua = true, help = true })[vim.bo.filetype] then
        vim.fn.execute('h ' .. vim.fn.expand('<cword>'))
      end
      vim.lsp.buf.hover()
    end, 'Hover Documentation')
    -- nmap('KK', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end,
})
