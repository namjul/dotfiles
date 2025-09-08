
-- Shorter version of the most frequent way of going outside of terminal window
vim.keymap.set('t', '<C-h>', [[<C-\><C-N><C-w>h]])

-- Paste before/after linewise
local cmd = vim.fn.has('nvim-0.12') == 1 and 'iput' or 'put'
vim.keymap.set({ 'n', 'x' }, '[p', '<Cmd>exe "' .. cmd .. '! " . v:register<CR>', { desc = 'Paste Above' })
vim.keymap.set({ 'n', 'x' }, ']p', '<Cmd>exe "' .. cmd .. ' "  . v:register<CR>', { desc = 'Paste Below' })

vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')

vim.keymap.set('n', "-",         "<CMD>Oil<CR>", {desc = "Open parent directory" })
vim.keymap.set('n', "<C-d>",     "<C-d>zz", { desc = "Up" } )
vim.keymap.set('n', "<C-u>",     "<C-u>zz", {desc = "Down" })
vim.keymap.set('n', "<Down>",    ":cnext<CR>", { desc = "Next in quickfix list" })
vim.keymap.set('n', "<Left>",    ":cpfile<CR>", { desc = "Last Error in quickfix list" })
vim.keymap.set('n', "<Right>",   ":cnfile<CR>", { desc = "First Error in quickfix list" })
vim.keymap.set('n', "<S-Down>",  ":lnext<CR>", { desc = "Next in location list" })
vim.keymap.set('n', "<S-Left>",  ":lpfile<CR>", { desc = "Last Error in location list" })
vim.keymap.set('n', "<S-Right>", ":lnfile<CR>", { desc = "First Error in location list" })
vim.keymap.set('n', "<S-Up>",    ":lprev<CR>", { desc = "Previous in location list" })
vim.keymap.set('n', "<Up>",      ":cprev<CR>", { desc = "Previous in quickfix list" })
vim.keymap.set('n', "J",         "mzJ`z", { desc = "Join lines" })
vim.keymap.set('n', "N",         "Nzzzv", { desc = "Search Previous" })
vim.keymap.set('n', "Q",         "", { desc = "avoid unintentional switches to Ex mode." })
vim.keymap.set('n', "gp",        ":lua MiniDiff.toggle_overlay()<CR>", { desc = "Toggle git hunks preview" })
vim.keymap.set('n', "gx",        ":!open <cWORD><CR>", { desc = "open url" })
vim.keymap.set('n', "n",         "nzzzv", { desc = "Search next" })

-- Store relative line number jumps in the jumplist if they exceed a threshold.
vim.keymap.set('n', 'k', function()
  return (vim.v.count > 5 and "m'" .. vim.v.count or '') .. 'k'
end, { expr = true })
vim.keymap.set('n', 'j', function()
  return (vim.v.count > 5 and "m'" .. vim.v.count or '') .. 'j'
end, { expr = true })

vim.keymap.set('i', "jk", "<Esc>")

-- place undo points after ending signs
vim.keymap.set('i', "!", "!<C-g>u")
vim.keymap.set('i', ",", ",<C-g>u")
vim.keymap.set('i', ".", ".<C-g>u")
vim.keymap.set('i', "?", "?<C-g>u")

vim.keymap.set('n', "<Leader><Leader>", "<Cmd>b#<CR>", { desc = "Alternate", noremap = true, silent = true })

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

-- b is for 'buffer'
nmap_leader("ba", "<Cmd>b#<CR>", "Alternate")
nmap_leader('bs', '<Cmd>lua Config.new_scratch_buffer()<CR>',    'Scratch')

-- f is for 'fuzzy find'
nmap_leader("ff", "<Cmd>lua require('namjul.functions.telescope').findFiles()<CR>", "Find Buffer" )
nmap_leader("fb", "<Cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy({}))<CR>", "Find Buffer" )
nmap_leader("fc", "<Cmd>lua require('namjul.functions.telescope').find_most_wanted()<CR>", "Find Most Wanted Folders" )
nmap_leader("fl", "<Cmd>lua require('namjul.functions.telescope').memex()<CR>",          "Search in Memex" )
nmap_leader("fd", "<Cmd>lua require('namjul.functions.telescope').search_dotfiles()<CR>", "Search dotfiles" )
nmap_leader("fgb", "<Cmd>lua require('telescope.builtin').git_branches(require('telescope.themes').get_ivy({}))<CR>", "Find branch" )
nmap_leader("fgc", "<Cmd>lua require('telescope.builtin').git_bcommits(require('telescope.themes').get_ivy({}))<CR>", "Find buffer commits" )
nmap_leader("fh", "<Cmd>lua require('telescope.builtin').help_tags(require('telescope.themes').get_ivy({}))<CR>", "Find Help" )
nmap_leader("fr", "<Cmd>lua require('namjul.functions.telescope').find_recent()<CR>", "Find Recent Files" )
nmap_leader('fs', function() require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_ivy({})) end, '[D]ocument [S]ymbols')
nmap_leader('fS', function() require('telescope.builtin').lsp_dynamic_workspace_symbols(require('telescope.themes').get_ivy({})) end, '[W]orkspace [S]ymbols')

-- exception
nmap_leader("*", "<Cmd>lua require('namjul.functions.telescope').grep_string()<CR>", "Grep word under cursor" )
nmap_leader("/", "<Cmd>lua require('namjul.functions.telescope').search({ previewer = false })<CR>", "Search word" )
nmap_leader("c", "<Cmd>lua require('telescope.builtin').commands(require('telescope.themes').get_ivy({}))<CR>", "Find Command" )

-- g is for git
nmap_leader("gl", "<Cmd>Gclog<CR>", "Open Git log" )
nmap_leader("gbl", "<Cmd>Gclog -- %<CR>", "Open Buffer Git log" )
nmap_leader("go", ':lua MiniDiff.toggle_overlay()<CR>', "Toggle hunk diff overlay")

nmap_leader("1", "<Cmd>RooterToggle<CR>", "Toggle Rooter" )
nmap_leader("2", "<Cmd>w<CR>:! ./%<CR>", "Execute current file" )
nmap_leader("3", "<Cmd>!chmod +x %<CR>", "Make current file executable" )
nmap_leader("m", "<Cmd>MaximizerToggle<CR>", "Maximize window" )
nmap_leader("o", "<Cmd>only<CR>", "Close all windows but active one" )
nmap_leader("q", "<Cmd>quit<CR>", "Quites the current window and vim if its the last" )
nmap_leader("te", "<Cmd>Trans en <CR>", "Translate to English(word under cursor)" )
nmap_leader("tg", "<Cmd>Trans de <CR>", "Translate to German(word under cursor)" )
nmap_leader("x", "<Cmd>exit<CR>", 'like ":wq"' )
nmap_leader("z", "<Cmd>ZenMode<CR>", "Enter Zenmode" )
nmap_leader("y", '"+y', "Yank into clipboard" )
xmap_leader("p", '"_dP"', "Paste without overide")
nmap_leader("p", function()
    local file = vim.fn.join({ vim.fn.expand('%'), vim.fn.line('.'), vim.fn.col('.') }, ':')
    vim.cmd('let @+="' .. file .. '"')
    print(file)
  end, "Show the path of the current file and add it to clipboard (mnemonic: path; useful when you have a lot of splits and the status line gets truncated).")
nmap_leader("R", function()
    -- Unload the lua namespace so that the next time require('config.X') is called
    -- it will reload the file
    require('namjul.utils').unload_lua_namespace('namjul')
    -- Make sure all open buffers are saved
    vim.cmd('silent wa')
    -- Execute our vimrc lua file again to add back our maps
    dofile(vim.fn.stdpath('config') .. '/init.lua')
    print('Reloaded vimrc!')
  end, "Reload vimrc")

local harpoon = require('harpoon')
nmap_leader("ha", function() harpoon:list():add() end, "Add file to harpoon" )
nmap_leader("hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "Toggle harpoon menu" )
nmap_leader("j", function() harpoon:list():select(1) end, "Harpoon: Goto(1)" )
nmap_leader("k", function() harpoon:list():select(2) end, "Harpoon: Goto(2)" )
nmap_leader("l", function() harpoon:list():select(3) end, "Harpoon: Goto(3)" )
nmap_leader("ö", function() harpoon:list():select(4) end, "Harpoon: Goto(4)" )



-- LSP
--------------------

vim.api.nvim_create_autocmd('User', {
  pattern = 'LspAttached',
  desc = 'LSP actions',
  callback = function(arg)
    nmap_leader('lk', function() vim.diagnostic.goto_prev({ enable_popup = false }) end, "Diagnostic Previous")
    nmap_leader('ll', function() vim.diagnostic.goto_next({ enable_popup = false }) end, "Diagnostic Previous")
    nmap_leader('la', vim.lsp.buf.code_action, '[C]ode [A]ction') -- conflicts with <leader>c

    nmap_leader('le', function() vim.diagnostic.open_float() end, "LSP open diagnostic")
    nmap_leader('li', function() vim.diagnostic.setloclist() end, "LSP open locallist")

    nmap_leader('lr', vim.lsp.buf.rename, '[R]e[n]ame')

    nmap_leader('ld', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap_leader('lR', vim.lsp.buf.references, '[G]oto [R]eferences')
    nmap_leader('lh', vim.lsp.buf.hover, '[G]oto [R]eferences')

    -- Create a command `:Format` local to the LSP buffer
    local bufnr = arg.data.bufnr
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end,
})
