
-- Shorter version of the most frequent way of going outside of terminal window
vim.keymap.set('t', '<C-h>', [[<C-\><C-N><C-w>h]])

-- Paste before/after linewise
local cmd = vim.fn.has('nvim-0.12') == 1 and 'iput' or 'put'
vim.keymap.set({ 'n', 'x' }, '[p', '<Cmd>exe "' .. cmd .. '! " . v:register<CR>', { desc = 'Paste Above' })
vim.keymap.set({ 'n', 'x' }, ']p', '<Cmd>exe "' .. cmd .. ' "  . v:register<CR>', { desc = 'Paste Below' })

vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')

vim.keymap.set('n', "-",         "<Cmd>Oil<CR>", {desc = "Open parent directory" })
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

-- use 'x' for cutting. works in conjuction with `vim-cutlass`
vim.keymap.set('n', 'x', 'd')
vim.keymap.set('x', 'x', 'd')
vim.keymap.set('n', 'xx', 'dd')
vim.keymap.set('n', 'X', 'D')

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

vim.keymap.set('n', 'K', function()
  if ({ vim = true, lua = true, help = true })[vim.bo.filetype] then
    vim.fn.execute('h ' .. vim.fn.expand('<cword>'))
  end
  vim.lsp.buf.hover()
end , { desc = 'Hover Documentation' })

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
nmap_leader('bd', '<Cmd>lua MiniBufremove.delete()<CR>',         'Delete')
nmap_leader('bD', '<Cmd>lua MiniBufremove.delete(0, true)<CR>',  'Delete!')
nmap_leader('bw', '<Cmd>lua MiniBufremove.wipeout()<CR>',        'Wipeout')
nmap_leader('bW', '<Cmd>lua MiniBufremove.wipeout(0, true)<CR>', 'Wipeout!')

-- e is for 'explore' and 'edit'
local edit_config_file = function(filename)
  return '<Cmd>edit ' .. vim.fn.stdpath('config') .. '/plugin/' .. filename .. '<CR>'
end
nmap_leader('ed', '<Cmd>Oil<CR>' , 'Directory')
nmap_leader('eo', edit_config_file('10_options.lua'), 'Options config')
nmap_leader('em', edit_config_file('11_mappings.lua'), 'Mappings config')
nmap_leader('ep', edit_config_file('20_plugins.lua'), 'Plugins config')
nmap_leader('eq', '<Cmd>lua Config.toggle_quickfix()<CR>', 'Quickfix')

-- f is for 'fuzzy find'
nmap_leader('f/', '<Cmd>Pick history scope="/"<CR>',                 '"/" history')
nmap_leader('f:', '<Cmd>Pick history scope=":"<CR>',                 '":" history')
nmap_leader('ff', '<Cmd>Pick files<CR>', 'Files')
nmap_leader('fb', '<Cmd>Pick buffers<CR>', 'Buffers')
nmap_leader('fc', '<Cmd>Pick git_commits<CR>', 'Commits (all)')
nmap_leader('fC', '<Cmd>Pick git_commits path="%"<CR>', 'Commits (current)')
nmap_leader('fh', '<Cmd>Pick help<CR>', 'Help tags')
nmap_leader('fH', '<Cmd>Pick hl_groups<CR>', 'Highlight groups')
nmap_leader('fl', '<Cmd>Pick buf_lines scope="all"<CR>', 'Lines (all)')
nmap_leader('fL', '<Cmd>Pick buf_lines scope="current"<CR>', 'Lines (current)')
nmap_leader('fR', '<Cmd>Pick lsp scope="references"<CR>', 'References (LSP)')
nmap_leader('fs', '<Cmd>Pick lsp scope="workspace_symbol"<CR>', 'Symbols workspace (LSP)')
nmap_leader('fS', '<Cmd>Pick lsp scope="document_symbol"<CR>', 'Symbols buffer (LSP)')
nmap_leader('fd', '<Cmd>Pick diagnostic scope="all"<CR>', 'Diagnostic workspace')
nmap_leader('fp', '<Cmd>Pick projects<CR>', 'Diagnostic workspace')
nmap_leader('fm', '<Cmd>Pick memex<CR>', 'Memex')
-- nmap_leader("fl", "<Cmd>lua require('namjul.functions.telescope').memex()<CR>",          "Search in Memex" )
-- nmap_leader("fd", "<Cmd>lua require('namjul.functions.telescope').search_dotfiles()<CR>", "Search dotfiles" )
-- nmap_leader("fr", "<Cmd>lua require('namjul.functions.telescope').find_recent()<CR>", "Find Recent Files" )

-- exception
nmap_leader('/', '<Cmd>Pick grep_live<CR>', 'Grep live')
nmap_leader('*', '<Cmd>Pick grep pattern="<cword>"<CR>', 'Grep current word')
nmap_leader('c', '<Cmd>Pick commands<CR>', 'Commands')

-- g is for 'git'
nmap_leader("gl", "<Cmd>Gclog<CR>", "Open Git log" )
nmap_leader("gL", "<Cmd>Gclog -- %<CR>", "Open Buffer Git log" )
nmap_leader("go", '<Cmd>lua MiniDiff.toggle_overlay()<CR>', "Toggle hunk diff overlay")
nmap_leader('ga', '<Cmd>Git diff --cached<CR>',                   'Added diff')
nmap_leader('gs', '<Cmd>Git<CR>')
nmap_leader('gc', '<Cmd>Git commit -v<CR>')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>')
nmap_leader('ga', '<Cmd>Git add -p<CR>')
nmap_leader('gp', '<Cmd>Git push<CR>')
nmap_leader('gd', '<Cmd>Gdiff<CR>')
nmap_leader('gw', '<Cmd>Gwrite<CR>')
nmap_leader('gbr', '<Cmd>GBrowse<CR>')
nmap_leader('gx', '<Cmd>lua MiniGit.show_at_cursor()<CR>',        'Show at cursor')

xmap_leader('gx', '<Cmd>lua MiniGit.show_at_cursor()<CR>',  'Show at selection')

-- L is for 'Lua'
nmap_leader('Lc', '<Cmd>lua Config.log_clear()<CR>', 'Clear log')
nmap_leader('Ls', '<Cmd>lua Config.log_print()<CR>', 'Show log')
nmap_leader('LL', '<Cmd>luafile %<CR><Cmd>echo "Sourced lua"<CR>', 'Source buffer')

-- o is for `other`
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>', 'Trim trailspace')
nmap_leader('oh', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notification history')
nmap_leader("oo", "<Cmd>only<CR>", "Close all windows but active one" )
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>',          'Zoom toggle')
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')

-- t is for 'terminal' (uses 'neoterm') and 'minitest'
nmap_leader('tT', '<Cmd>belowright Tnew<CR>',                          'Terminal (horizontal)')
nmap_leader('tt', '<Cmd>vertical Tnew<CR>',                            'Terminal (vertical)')

-- misc
nmap_leader("2", "<Cmd>w<CR>:! ./%<CR>", "Execute current file" )
nmap_leader("3", "<Cmd>!chmod +x %<CR>", "Make current file executable" )
nmap_leader("q", "<Cmd>quit<CR>", "Quites the current window and vim if its the last" )
nmap_leader("te", "<Cmd>Trans en <CR>", "Translate to English(word under cursor)" )
nmap_leader("tg", "<Cmd>Trans de <CR>", "Translate to German(word under cursor)" )
nmap_leader("x", "<Cmd>exit<CR>", 'like ":wq"' )
nmap_leader("z", "<Cmd>ZenMode<CR>", "Enter Zenmode" )
nmap_leader("y", '"+y', "Yank into clipboard" )
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

local has_harpoon, harpoon = pcall(require, 'harpoon')
if has_harpoon then
  nmap_leader("ha", function() harpoon:list():add() end, "Add file to harpoon" )
  nmap_leader("hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "Toggle harpoon menu" )
  nmap_leader("j", function() harpoon:list():select(1) end, "Harpoon: Goto(1)" )
  nmap_leader("k", function() harpoon:list():select(2) end, "Harpoon: Goto(2)" )
  nmap_leader("l", function() harpoon:list():select(3) end, "Harpoon: Goto(3)" )
  nmap_leader("ö", function() harpoon:list():select(4) end, "Harpoon: Goto(4)" )
end

xmap_leader("p", '"_dP"', "Paste without overide")

-- l is for 'LSP' (Language Server Protocol)
local formatting_cmd = '<Cmd>lua require("conform").format({ lsp_fallback = true })<CR>'
nmap_leader('lf', formatting_cmd, 'Format')

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
