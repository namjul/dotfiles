namjul.functions.plaintext()

local has_shellbot = require('chatbot')
if has_shellbot then
  ---@diagnostic disable-next-line: undefined-global
  vim.keymap.set({ 'i', 'n' }, '<M-CR>', ChatBotSubmit, { buffer = true })
end
