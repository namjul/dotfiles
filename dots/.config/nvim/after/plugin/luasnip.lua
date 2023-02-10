local has_luasnip = pcall(require, 'luasnip')

if not has_luasnip then
  return
end

-- local ls = require('luasnip')


-- https://github.com/dendronhq/dendron-template/blob/master/vault/.vscode/dendron.code-snippets

-- already exists in friendly-snippets with `task`
-- ls.add_snippets('markdown', {
--   s('td', {
--     t('- [ ] '),
--     i(1)
--   })
-- }, { key = 'all' })
--
-- local getUrlTitle = require('namjul.functions.getUrlTitle')
-- local s = ls.snippet
-- local sn = ls.snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- -- local c = ls.choice_node
-- local d = ls.dynamic_node
-- -- local r = ls.restore_node
-- -- local types = require('luasnip.util.types')
--
-- ls.add_snippets('markdown', {
--   s('[c', {
--     t('['),
--     d(1, function()
--       local copy = string.gsub(vim.fn.getreg('+'), '\n', '')
--       local title = getUrlTitle(copy)
--       return sn(nil, {
--         i(1, title or copy),
--       })
--     end, { 1 }),
--
--     t(']('),
--     f(function()
--       return string.gsub(vim.fn.getreg('+'), '\n', '')
--     end, {}),
--     t(')'),
--     i(0),
--   }),
-- }, { key = 'all' })

-- require('luasnip.loaders.from_vscode').lazy_load()
