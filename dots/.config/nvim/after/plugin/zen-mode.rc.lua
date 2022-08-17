local has_zen_mode_mode = pcall(require, 'zen-mode')

if not has_zen_mode_mode then
  return
end

require('zen-mode').setup({})
