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
        return "javascript"
      end
    end,
  },
  extension = {
    tsx = function(_, bufnr)
      local has_tsx_filetype = function()
        return vim.regex('\\v<tsx>'):match_str(vim.bo[bufnr].filetype)
      end

      if not has_tsx_filetype() then
        return 'typescript.tsx'
      end
      return 'typescript'
    end,
    jsx = function(_, bufnr)
      local has_jsx_filetype = function()
        return vim.regex('\\v<jsx>'):match_str(vim.bo[bufnr].filetype)
      end

      if not has_jsx_filetype() then
        return 'javascript.jsx'
      end
      return 'javascript'
    end
  }
})
