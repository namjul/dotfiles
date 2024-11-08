local has_ccc = pcall(require, 'ccc')

if not has_ccc then
  return
end

require('ccc').setup({
  highlighter = {
    auto_enable = true
  }
})
