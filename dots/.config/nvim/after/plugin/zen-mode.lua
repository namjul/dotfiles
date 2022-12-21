local has_zen_mode_mode = pcall(require, 'zen-mode')

if not has_zen_mode_mode then
  return
end

require('zen-mode').setup({
  window = {
    width = 90,
    options = {
      number = true,
      relativenumber = true,
    },
  },
})
