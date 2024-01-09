local getUrlTitle = require('namjul.functions.getUrlTitle')

vim.api.nvim_create_user_command('PreviewMarkdown', function()
  vim.cmd("VimuxRunCommand('echo ' . expand('%:p') . ' | entr -c -c glow ' . expand('%:p'))")
end, {})

vim.api.nvim_create_user_command('PasteMDLink', function()
  local url = vim.fn.getreg('+')
  local title = getUrlTitle(url)
  if title then
    local mdLink = string.format('[%s](%s)', title, url)
    vim.cmd('normal! a' .. mdLink)
  end
end, {})

local has_rest_nvim = pcall(require, 'rest-nvim')

if not has_rest_nvim then
  return
end

local restNvim = require('rest-nvim')

vim.api.nvim_create_user_command('RestNvim', function()
  restNvim.run()
end, {})

vim.api.nvim_create_user_command('RestNvimPreview', function()
  restNvim.run(true)
end, {})

vim.api.nvim_create_user_command('RestNvimLast', function()
  restNvim.last()
end, {})
