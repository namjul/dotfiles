local has_debugprint = pcall(require, 'debugprint')

if not has_debugprint then
  return
end

require('debugprint').setup({
  create_keymaps = false,
})
