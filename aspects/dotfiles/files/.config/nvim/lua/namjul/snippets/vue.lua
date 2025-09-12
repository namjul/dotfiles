local luasnip = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt

local typescript = require('namjul.snippets.common.typescript')

local s = luasnip.snippet
local i = luasnip.insert_node

luasnip.add_snippets('vue', typescript)

-- TODO use choice to dynamically create nuanced snippets
luasnip.add_snippets('vue', {
  s(
    { trig = 'vbase', dscr = 'todo' },
    fmt(
      [[
      <script setup lang="ts">

      </script>
      <template>
        <div>
          {}
        </div>
      </template>
      <style scoped>

      </style>
    ]],
      {
        i(0),
      }
    )
  ),
})
