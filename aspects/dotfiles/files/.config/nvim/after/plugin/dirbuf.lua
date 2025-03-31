local has_dirbuf = pcall(require, 'dirbuf')

if not has_dirbuf then
  return
end

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('dirbuf').setup({
  hash_padding = 2,
  show_hidden = true,
  sort_order = 'directories_first',
  write_cmd = 'DirbufSync',
})
