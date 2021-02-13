local pinnacle = require'wincent.pinnacle'
local util = require('namjul.utils')
local cmd = vim.cmd

local defaultLhsColor = 'GruvboxFg4'
local modifiedLhsColor = 'GruvboxGreen'
local statusHighlight = defaultLhsColor

local statusline = {}

local defaultStl = {
  '%4*', -- Switch to User4 highlighting group
  '%(', -- start item group
  ' %{luaeval("require\'namjul.statusline\'.mode()")} ',
  '%)', -- end item group
  '%*', -- reset highlighting group
  ' ', -- Space
  '%<', -- Truncation point, if not enough width available.
  '%f', -- path to the file in the buffer, as typed or relative to current directory.
  ' ', -- Space.
  '%3*', -- Switch to User3 highlight group (italics).
  '%(', -- Start item group.
  '[', -- Left bracket (literal).
  '%R', -- Read-only flag
  '%{luaeval("require\'namjul.statusline\'.filetype()")}',
  '%{luaeval("require\'namjul.statusline\'.fileencoding()")}', -- File-encoding if not UTF-8.
  ']', -- Right bracket (literal).
  '%)', -- End item group.
  '%*', -- Reset highlight group.
  ' ', -- Space.
  '%=', -- switch to right side
  '%5*', -- Switch to User5 highlight group (italics).
  '%{luaeval("require\'namjul.statusline\'.rhs()")}',
  '%*', -- Reset highlight group.
}


local mode_map = {
  ['n'] = 'N',
	['no'] = 'n·operator pending',
	['v'] = 'V',
	['V'] = 'V·line',
	[''] = 'V·block',
	['s'] = 'select',
	['S'] = 'S·line',
	[''] = 'S·block',
	['i'] = 'I',
	['R'] = 'replace',
	['Rv'] = 'V·replace',
	['c'] = 'command',
	['cv'] = 'vim ex',
	['ce'] = 'ex',
	['r'] = 'prompt',
	['rm'] = 'more',
	['r?'] = 'confirm',
	['!'] = 'shell',
	['t'] = 'terminal'
}

function statusline.mode()
	local m = vim.api.nvim_get_mode().mode
	if mode_map[m] == nil then return m end
	return mode_map[m]
end

function statusline.updateHighlight()

  -- colors
  local bg0 = pinnacle.extract_fg('GruvboxBg0')
  local bg1 = pinnacle.extract_fg('GruvboxBg1')
  local bg2 = pinnacle.extract_fg('GruvboxBg2')
  local bg4 = pinnacle.extract_fg('GruvboxBg4')
  local fg1 = pinnacle.extract_fg('GruvboxFg1')
  local fg4 = pinnacle.extract_fg('GruvboxFg4')

  local yellow = pinnacle.extract_fg('GruvboxYellow')
  local blue = pinnacle.extract_fg('GruvboxBlue')
  local aqua = pinnacle.extract_fg('GruvboxAqua')
  local orange = pinnacle.extract_fg('GruvboxOrange')
  local green = pinnacle.extract_fg('GruvboxGreen')


  local modeColor = pinnacle.extract_fg(statusHighlight)

  -- Default StatusLine
  cmd('highlight User1 ' .. pinnacle.highlight({
    bg = bg1,
    fg = fg4,
  }))

  -- Inactive StatusLine
  cmd('highlight User2 ' .. pinnacle.highlight({
    bg = bg1,
    fg = bg4,
  }))

  -- For file meta info
  local highlight = pinnacle.italicize('User1')
  cmd('highlight User3 ' .. highlight)

  -- lhs
  cmd('highlight User4 ' .. pinnacle.highlight({
    bg = modeColor,
    fg = bg0,
    cterm = 'bold'
  }))

  -- rhs
  cmd('highlight User5 ' .. pinnacle.highlight({
    bg = fg4,
    fg = bg0,
  }))


  cmd('highlight! link StatusLine User1')
  cmd('highlight clear StatusLineNC')
  cmd('highlight! link StatusLineNC User2')
end

function statusline.filetype()
  local filetype = vim.bo.filetype
  if #filetype > 0 then
    return ',' .. filetype
  else
    return ''
  end
end

-- Returns the 'fileencoding', if it's not UTF-8.
function statusline.fileencoding()
  local fileencoding = vim.bo.fileencoding
  if #fileencoding > 0 and fileencoding ~= 'utf-8' then
    return ',' .. fileencoding
  else
    return ''
  end
end

-- Source: https://github.com/wincent/wincent/blob/851284ad9ef623442384176c8b96b52a6cba6c9e/aspects/vim/files/.vim/lua/wincent/statusline.lua#L174
function statusline.rhs()
  local rhs = ''

  if vim.fn.winwidth(0) > 80 then
    local column = vim.fn.virtcol('.')
    local width = vim.fn.virtcol('$')
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local height = vim.api.nvim_buf_line_count(0)

    -- Add padding to stop RHS from changing too much as we move the cursor.
    local padding = #tostring(height) - #tostring(line)
    if padding > 0 then
      rhs = rhs .. string.rep(' ', padding)
    end

    rhs = rhs .. ' ℓ '
    rhs = rhs .. line
    rhs = rhs .. '/'
    rhs = rhs .. height
    rhs = rhs .. ' 𝘤 '
    rhs = rhs .. column
    rhs = rhs .. '/'
    rhs = rhs .. width
    rhs = rhs .. ' '

    -- Add padding to stop rhs from changing too much as we move the cursor.
    if #tostring(column) < 2 then
      rhs = rhs .. ' '
    end
    if #tostring(width) < 2 then
      rhs = rhs .. ' '
    end
  end

  return rhs
end

function statusline.focus()
  statusline.update(nil, 'focus') -- revert to default 'statusline'
end

function statusline.blur()
  statusline.update({
    ' ', -- space
    ' ', -- space
    ' ', -- space
    ' ', -- space
    '%<', -- truncation point
    '%f', -- filename
    '%=', -- split left/right halves (makes background cover whole)
  }, 'blur')
end

function statusline.checkModified()
  local modified = util.opt.b('modified')

  if modified and statusHighlight ~= modifiedLhsColor then
    statusHighlight = modifiedLhsColor
    statusline.updateHighlight()
  elseif not modified then
    statusHighlight = defaultLhsColor
    statusline.updateHighlight()
  end
end

function statusline.update(stl, action)
  stl = stl or defaultStl
  util.opt.w({
    statusline = type(stl) == 'table' and table.concat(stl) or stl,
  })
  util.opt.g({
    showmode = false,
  })
end

function statusline.set()
  statusline.update(defaultStl)
end

return statusline
