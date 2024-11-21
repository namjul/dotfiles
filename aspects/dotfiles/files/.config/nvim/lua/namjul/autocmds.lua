local util = require('namjul.utils')
local cmd = vim.cmd

local autocmds = {}

local winhighlight_blurred = table.concat({
  'CursorLineNr:LineNr',
  'EndOfBuffer:ColorColumn',
  'IncSearch:ColorColumn',
  'Normal:ColorColumn',
  'NormalNC:ColorColumn',
  'Search:ColorColumn',
  'SignColumn:ColorColumn',
  'VertSplit:VertSplitBlur',
}, ',')

local function set_cursorline(active)
  util.opt.w({ cursorline = active })
end

local function focus_window()
  local filetype = vim.bo.filetype

  -- Turn on relative numbers
  if filetype ~= '' and autocmds.number_blacklist[filetype] ~= true then
    vim.wo.number = true
    vim.wo.relativenumber = true
  end

  if filetype == '' or autocmds.winhighlight_filetype_blacklist[filetype] ~= true then
    vim.wo.winhighlight = ''
  end

  if filetype == '' then
    vim.wo.list = true
  else
    local list = autocmds.list_filetypes[filetype]
    if list == nil then
      vim.wo.list = true
    else
      vim.wo.list = list
    end
  end

  local conceallevel = autocmds.conceallevel_filetypes[filetype] or 2
  vim.wo.conceallevel = conceallevel

end

local function blur_window()

  local filetype = vim.bo.filetype

  -- Turn off relative numbers (and turn on non-relative numbers)
  if filetype ~= '' and autocmds.number_blacklist[filetype] ~= true then
    vim.wo.number = true
    vim.wo.relativenumber = false
  end

  if filetype == '' or autocmds.winhighlight_filetype_blacklist[filetype] ~= true then
    vim.wo.winhighlight = winhighlight_blurred
  end

  if filetype == '' then
    vim.wo.list = false
  else
    local list = autocmds.list_filetypes[filetype]
    if list == nil then
      vim.wo.list = false
    else
      vim.wo.list = list
    end
  end

  if filetype == '' or autocmds.conceallevel_filetypes[filetype] == nil then
    vim.wo.conceallevel = 0
  end

end

-- local function rooter(ctx)
--   local root = vim.fs.root(ctx.buf, {".git", "Makefile"})
--   if root then vim.uv.chdir(root) end
-- end

function autocmds.bufEnter()
  focus_window()
  -- rooter()
end

function autocmds.bufLeave()
  -- print('bufLeave not specified')
end

function autocmds.bufWinEnter()
  -- print('bufWinEnter not specified')
end

function autocmds.bufWritePost()
  -- print('bufWritePost not specified')
end

function autocmds.focusGained()
  focus_window()
end

function autocmds.focusLost()
  blur_window()
end

function autocmds.insertEnter()
  set_cursorline(false)
end

function autocmds.insertLeave()
  set_cursorline(true)
end

function autocmds.vimEnter()
  focus_window()
  set_cursorline(true)
end

function autocmds.winEnter()
  focus_window()
  set_cursorline(true)
end

function autocmds.winLeave()
  blur_window()
  set_cursorline(false)
end

function autocmds.skeleton(path)
  cmd('0r ' .. path)
end

autocmds.winhighlight_filetype_blacklist = {
  ['diff'] = true,
  ['fugitiveblame'] = true,
  ['undotree'] = true,
  ['qf'] = true,
  ['TelescopePrompt'] = true
}

-- Force 'list' (when `true`) or 'nolist' (when `false`) for these.
autocmds.list_filetypes = {
  ['help'] = false,
  ['shellbot'] = false,
  ['TelescopePrompt'] = false
}
--
-- Don't mess with 'conceallevel' for these.
autocmds.conceallevel_filetypes = {
  ['oil'] = 2,
  ['help'] = 2,
}

-- Don't mess with numbers in these filetypes.
autocmds.number_blacklist = {
  ['diff'] = true,
  ['fugitiveblame'] = true,
  ['help'] = true,
  ['qf'] = true,
  ['shellbot'] = true,
  ['undotree'] = true,
  ['TelescopePrompt'] = true
}

return autocmds
