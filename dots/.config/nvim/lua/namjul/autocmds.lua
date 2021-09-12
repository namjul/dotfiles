local util = require('namjul.utils')
local statusline = require('namjul.statusline')
local cmd = vim.cmd

local focusedFlag = 'namjulFocused'
local autocmds = {}

local winhighlightBlurred = table.concat({
  'CursorLineNr:LineNr',
  'EndOfBuffer:ColorColumn',
  'IncSearch:ColorColumn',
  'Normal:ColorColumn',
  'NormalNC:ColorColumn',
  'SignColumn:ColorColumn',
}, ',')

local function setCursorline(active)
  util.opt.w({ cursorline = active })
end

local function supportsBlurFocus(callback)
  local filetype = util.opt.b('filetype')
  local listed = util.opt.b('buflisted')
  if autocmds.filetypeBlacklist[filetype] ~= true and listed then
    callback(filetype)
  end
end

local function focusWindow()
  if util.var.g(focusedFlag) ~= true then
    util.opt.w({ winhighlight = '' })
    supportsBlurFocus(function()
      util.opt.w({
        conceallevel = 0,
        list = true,
      })
    end)
    util.var.g({ [focusedFlag] = true })
    statusline.focus()
  end
end

local function blurWindow()
  if util.var.g(focusedFlag) ~= false then
    util.opt.w({ winhighlight = winhighlightBlurred })
    supportsBlurFocus(function()
      util.opt.w({
        conceallevel = 0, -- disabled now since currently wikilinks in markdown files get completely hidden
        list = false,
      })
    end)
    util.var.g({ [focusedFlag] = false })
    statusline.blur()
  end
end

function autocmds.bufEnter()
  focusWindow()
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
  focusWindow()
end

function autocmds.focusLost()
  blurWindow()
end

function autocmds.insertEnter()
  setCursorline(false)
end

function autocmds.insertLeave()
  setCursorline(true)
end

function autocmds.vimEnter()
  focusWindow()
  setCursorline(true)
end

function autocmds.winEnter()
  focusWindow()
  setCursorline(true)
end

function autocmds.winLeave()
  blurWindow()
  setCursorline(false)
end

function autocmds.skeleton(path)
  cmd('0r ' .. path)
end

autocmds.filetypeBlacklist = {
  ['dirvish'] = true,
}

return autocmds
