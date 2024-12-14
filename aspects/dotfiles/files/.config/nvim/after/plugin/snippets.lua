local has_luasnip = pcall(require, 'luasnip')

if not has_luasnip then
  return
end

-- https://github.com/dendronhq/dendron-template/blob/master/vault/.vscode/dendron.code-snippets

-- Tell LuaSnip to load on demand based on file-type.
require('luasnip.loaders.from_lua').load({
  lazy_paths = "~/.config/nvim/lua/namjul/snippets",
  paths = "~/.config/nvim/lua/namjul/snippets/all.lua"
})


-- uuid
-- console.log
-- export default named function
-- snippets/global.json
