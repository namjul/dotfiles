-- lua file detection feature:
-- https://github.com/neovim/neovim/pull/16600#issuecomment-990409210

vim.filetype.add({
  filename = {
    ["TODO"] = function()
      return "markdown"
    end,
    ["foo.(%a+)"] = function(_, _, ext)
      -- The 'ext' argument is the captured match from the filename pattern
      return ext
    end,
  },
  pattern = {
    [".*"] = function()
      local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
      if first_line:match("^#!/usr/bin/env zx") then
        return "typescript"
      end
    end,
  }
})
