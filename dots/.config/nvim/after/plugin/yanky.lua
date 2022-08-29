local has_yanky = pcall(require, 'yanky')

if not has_yanky then
  return
end

require('yanky').setup({
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 200,
  },
  preserve_cursor_position = {
    enabled = true,
  },
})
