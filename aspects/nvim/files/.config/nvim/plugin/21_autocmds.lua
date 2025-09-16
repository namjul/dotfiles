local H = {}

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
  callback = function() H.skeleton('~/.config/nvim/templates/skeleton.sh') end,
  group = 'NamjulSkeletons',
})
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesActionCreate',
  callback = function(args)
    if H.has_extension(args.data.to, 'sh') then
      H.append_skeleton_to_file(args.data.to, '~/.config/nvim/templates/skeleton.sh')
    end
    if H.has_extension(args.data.to, 'html') then
      H.append_skeleton_to_file(args.data.to, '~/.config/nvim/templates/skeleton.html')
    end
    if H.has_extension(args.data.to, 'http') then
      H.append_skeleton_to_file(args.data.to, '~/.config/nvim/templates/skeleton.http')
    end
  end,
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

-- Helper ===

function H.skeleton(path) vim.cmd('0r ' .. path) end

function H.append_skeleton_to_file(target_path, skeleton_path)
  -- Expand paths to handle ~ or other variables
  target_path = vim.fn.expand(target_path)
  skeleton_path = vim.fn.expand(skeleton_path)

  -- Read skeleton file
  local ok, skeleton_lines = pcall(vim.fn.readfile, skeleton_path)
  if not ok then
    vim.notify('Failed to read skeleton file: ' .. skeleton_path, vim.log.levels.ERROR)
    return false
  end

  -- Append to target file
  local file, err = io.open(target_path, 'a') -- Open in append mode
  if not file then
    vim.notify('Failed to open target file: ' .. target_path .. ' (' .. err .. ')', vim.log.levels.ERROR)
    return false
  end

  -- Write skeleton lines
  for _, line in ipairs(skeleton_lines) do
    file:write(line .. '\n') -- Append each line with newline
  end
  file:close()
  return true
end

function H.has_extension(path, ext)
  local file_ext = vim.fn.fnamemodify(path, ':e') -- Gets the extension (e.g., "sh")
  -- Normalize ext (remove leading dot if present)
  ext = ext:gsub('^%.', '')
  return file_ext == ext
end
