
-- Shorter version of the most frequent way of going outside of terminal window
vim.keymap.set('t', '<C-h>', [[<C-\><C-N><C-w>h]])

-- Paste before/after linewise
local cmd = vim.fn.has('nvim-0.12') == 1 and 'iput' or 'put'
vim.keymap.set({ 'n', 'x' }, '[p', '<Cmd>exe "' .. cmd .. '! " . v:register<CR>', { desc = 'Paste Above' })
vim.keymap.set({ 'n', 'x' }, ']p', '<Cmd>exe "' .. cmd .. ' "  . v:register<CR>', { desc = 'Paste Below' })

vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')

vim.keymap.set('n', "-",         "<CMD>Oil<CR>", {desc = "Open parent directory", nowait = false, remap = false })
vim.keymap.set('n', "<C-d>",     "<C-d>zz", { desc = "Up", nowait = false, remap = false } )
vim.keymap.set('n', "<C-u>",     "<C-u>zz", {desc = "Down", nowait = false, remap = false })
vim.keymap.set('n', "<Down>",    ":cnext<CR>", { desc = "Next in quickfix list", nowait = false, remap = false })
vim.keymap.set('n', "<Left>",    ":cpfile<CR>", { desc = "Last Error in quickfix list", nowait = false, remap = false })
vim.keymap.set('n', "<Right>",   ":cnfile<CR>", { desc = "First Error in quickfix list", nowait = false, remap = false })
vim.keymap.set('n', "<S-Down>",  ":lnext<CR>", { desc = "Next in location list", nowait = false, remap = false })
vim.keymap.set('n', "<S-Left>",  ":lpfile<CR>", { desc = "Last Error in location list", nowait = false, remap = false })
vim.keymap.set('n', "<S-Right>", ":lnfile<CR>", { desc = "First Error in location list", nowait = false, remap = false })
vim.keymap.set('n', "<S-Up>",    ":lprev<CR>", { desc = "Previous in location list", nowait = false, remap = false })
vim.keymap.set('n', "<Up>",      ":cprev<CR>", { desc = "Previous in quickfix list", nowait = false, remap = false })
vim.keymap.set('n', "<c-k>",     ":lua require('namjul.functions.telescope').findFiles()<CR>", { desc = "Go to File", nowait = false, remap = false })
vim.keymap.set('n', "<c-s>",     "<Plug>(Switch)", { desc = "Switch", nowait = false, remap = false })
vim.keymap.set('n', "J",         "mzJ`z", { desc = "Join lines", nowait = false, remap = false })
vim.keymap.set('n', "N",         "Nzzzv", { desc = "Search Previous", nowait = false, remap = false })
vim.keymap.set('n', "Q",         "", { desc = "avoid unintentional switches to Ex mode.", nowait = false, remap = false })
vim.keymap.set('n', "gp",        ":lua MiniDiff.toggle_overlay()<CR>", { desc = "Toggle git hunks preview", nowait = false, remap = false })
vim.keymap.set('n', "gx",        ":!open <cWORD><CR>", { desc = "open url", nowait = false, remap = false })
vim.keymap.set('n', "n",         "nzzzv", { desc = "Search next", nowait = false, remap = false })

-- Store relative line number jumps in the jumplist if they exceed a threshold.
vim.keymap.set('n', 'k', function()
  return (vim.v.count > 5 and "m'" .. vim.v.count or '') .. 'k'
end, { expr = true })
vim.keymap.set('n', 'j', function()
  return (vim.v.count > 5 and "m'" .. vim.v.count or '') .. 'j'
end, { expr = true })

-- Leader mappings ===

-- Create `<Leader>` mappings
local nmap_leader = function(suffix, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, opts)
end
local xmap_leader = function(suffix, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, opts)
end

local wk = require('which-key')
local harpoon = require('harpoon')

-- LEADER
--------------------


-- NORMAL
--------------------

wk.add({
})

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
  { "<leader>ff", ":lua require('namjul.functions.telescope').findFiles()<CR>", desc = "Find Buffer", nowait = false, remap = false },
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
  { "<leader>o", ":only<CR>", desc = "Close all windows but active one", nowait = false, remap = false },
  { "<leader>p", function()
      local file = vim.fn.join({ vim.fn.expand('%'), vim.fn.line('.'), vim.fn.col('.') }, ':')
      vim.cmd('let @+="' .. file .. '"')
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
  },
}
)

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
      { "jk",    "<Esc>",                                      desc = "Esc Mapping",          nowait = false, remap = false },
    },
  }
)


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
