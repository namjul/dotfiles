local has_tabout = pcall(require, 'tabout')

if not has_tabout then
  return
end

require('tabout').setup({})
