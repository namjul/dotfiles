local bg = vim.o.background

require('gruvbox').setup({
  overrides = {
    SignColumn = { bg = bg == 'light' and "#fbf1c7" or "#282828" },
    NormalFloat = { bg = bg == 'light' and "#fbf1c7" or "#282828" },
  }
})
require("gruvbox").load()

vim.g.colors_name = "custom_gruvbox"
