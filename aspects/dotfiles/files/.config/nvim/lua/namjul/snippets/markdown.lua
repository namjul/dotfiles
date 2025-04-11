local luasnip = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt
local getUrlTitle = require('namjul.functions.getUrlTitle')

local s = luasnip.snippet
local sn = luasnip.snippet_node
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node
-- local c = ls.choice_node
local d = luasnip.dynamic_node
-- local r = ls.restore_node
-- local types = require('luasnip.util.types')

luasnip.add_snippets('markdown', {
  s({ trig = 'code' }, fmt('`{}`', { i(1, 'value') }))
})

luasnip.add_snippets('markdown', {
  s({ trig = 'codeblock' }, fmt('```{}\n{}\n```', { i(1, 'value'), i(2, 'value') }))
})

luasnip.add_snippets('markdown', {
  s({ trig = 'td' }, fmt('- [{}]', { i(1, 'value') }))
})

luasnip.add_snippets('markdown', {
  s({ trig = 'link' }, fmt('[{}]({})', { i(1, 'value'),  i(2, 'value')  }))
})

luasnip.add_snippets('markdown', {
  s('[c', {
    t('['),
    d(1, function()
      local copy = string.gsub(vim.fn.getreg('+'), '\n', '')
      local title = getUrlTitle(copy)
      return sn(nil, {
        i(1, title or copy),
      })
    end, { 1 }),

    t(']('),
    f(function()
      return string.gsub(vim.fn.getreg('+'), '\n', '')
    end, {}),
    t(')'),
    i(0),
  }),
}, { key = 'all' })

luasnip.add_snippets('markdown', {
  s(
    { trig = 'frontmatter', dscr = 'Document frontmatter' },
    fmt(
      [[
      ---
      tags: {}
      ---

    ]],
      {
        i(1, 'value'),
      }
    )
  ),
})
