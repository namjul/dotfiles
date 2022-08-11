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
