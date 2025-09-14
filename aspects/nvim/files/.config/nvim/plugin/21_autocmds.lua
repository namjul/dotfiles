-- Create autocommand group for general autocommands
vim.api.nvim_create_augroup('NamjulAutocmds', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function() require('namjul.autocmds').bufEnter() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('BufLeave', {
  pattern = '*',
  callback = function() require('namjul.autocmds').bufLeave() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function() require('namjul.autocmds').bufWinEnter() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*',
  callback = function() require('namjul.autocmds').bufWritePost() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('FocusGained', {
  pattern = '*',
  callback = function() require('namjul.autocmds').focusGained() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('FocusLost', {
  pattern = '*',
  callback = function() require('namjul.autocmds').focusLost() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  callback = function() require('namjul.autocmds').insertEnter() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  callback = function() require('namjul.autocmds').insertLeave() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  command = 'set nopaste',
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function() require('namjul.autocmds').vimEnter() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('WinEnter', {
  pattern = '*',
  callback = function() require('namjul.autocmds').winEnter() end,
  group = 'NamjulAutocmds',
})
vim.api.nvim_create_autocmd('WinLeave', {
  pattern = '*',
  callback = function() require('namjul.autocmds').winLeave() end,
  group = 'NamjulAutocmds',
})

-- Create autocommand group for skeleton templates
vim.api.nvim_create_augroup('NamjulSkeletons', { clear = true })
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.sh',
  callback = function() require('namjul.autocmds').skeleton('~/.config/nvim/templates/skeleton.sh') end,
  group = 'NamjulSkeletons',
})
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.html',
  callback = function() require('namjul.autocmds').skeleton('~/.config/nvim/templates/skeleton.html') end,
  group = 'NamjulSkeletons',
})
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.http',
  callback = function() require('namjul.autocmds').skeleton('~/.config/nvim/templates/skeleton.http') end,
  group = 'NamjulSkeletons',
})

-- Create autocommand group for JSONC filetype
vim.api.nvim_create_augroup('JsoncFiletype', { clear = true })
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = 'tsconfig*.json',
  command = 'set filetype=jsonc',
  group = 'JsoncFiletype',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'neoterm',
  callback = function()
    vim.defer_fn(function() vim.opt_local.signcolumn = 'yes' end, 50)
  end,
})
