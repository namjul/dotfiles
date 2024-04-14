local fn = vim.fn

local M = {}

-- Inspired by: https://github.com/wincent/wincent/blob/cb5b2aa367e1726532199cca8b78a989fd3aaf44/aspects/vim/files/.vim/autoload/wincent/tabline.vim#L1
-- Cleaner/simpler clone of the built-in tabline, but without the window counts, the modified flag, or the close widget.

function M.line()
  local line = ''
  local current = fn.tabpagenr()

  for i = 1, fn.tabpagenr('$') do
    if i == current then
      line = line .. '%#TabLineSel#'
    else
      line = line .. '%#TabLine#'
    end
    line = line .. '%' .. i .. 'T' -- Starts mouse click target region.
    line = line .. ' ' .. M.label(i) .. ' '
  end

  line = line .. '%#TabLineFill#'
  line = line .. '%T' -- Ends mouse click target region(s).

  return line
end

function M.label(n)
  local buflist = fn.tabpagebuflist(n)
  local winnr = fn.tabpagewinnr(n)
  return fn.pathshorten(fn.fnamemodify(fn.bufname(buflist[winnr]), ':~:.'))
end

return M
