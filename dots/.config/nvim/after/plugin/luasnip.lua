local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- local types = require('luasnip.util.types')

ls.config.setup({
  -- ext_opts = {
  --   [types.choiceNode] = {
  --     active = {
  --       virt_text = { { '●', 'GruvboxOrange' } },
  --     },
  --   },
  --   [types.insertNode] = {
  --     active = {
  --       virt_text = { { '●', 'GruvboxBlue' } },
  --     },
  --   },
  -- },
})


-- https://github.com/dendronhq/dendron-template/blob/master/vault/.vscode/dendron.code-snippets

ls.add_snippets('markdown', {
  s('td', {
    t('- [ ] '),
    i(1)
  })
}, { key = 'all' })
