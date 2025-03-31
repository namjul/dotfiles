local has_nvim_tree = pcall(require, 'nvim-tree')

if not has_nvim_tree then
  return
end

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
