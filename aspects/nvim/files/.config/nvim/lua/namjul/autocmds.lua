-- This is inspired by https://github.com/wincent/wincent/blob/main/aspects/nvim/files/.config/nvim/lua/wincent/autocmds.lua

local H = {}
local AutoCmds = {}

function AutoCmds.bufEnter() H.focus_window() end

function AutoCmds.bufLeave() H.mkview() end

function AutoCmds.bufWinEnter()
  if H.should_mkview() then vim.cmd('silent! loadview') end
end

function AutoCmds.bufWritePost() H.mkview() end

function AutoCmds.focusGained() H.focus_window() end

function AutoCmds.focusLost() H.blur_window() end

function AutoCmds.insertEnter() H.set_cursorline(false) end

function AutoCmds.insertLeave() H.set_cursorline(true) end

function AutoCmds.vimEnter()
  H.focus_window()
  H.set_cursorline(true)
end

function AutoCmds.winEnter()
  H.focus_window()
  H.set_cursorline(true)
end

function AutoCmds.winLeave()
  H.blur_window()
  H.set_cursorline(false)
end

AutoCmds.winhighlight_filetype_blacklist = {
  ['diff'] = true,
  ['fugitiveblame'] = true,
  ['undotree'] = true,
  ['qf'] = true,
  ['TelescopePrompt'] = true,
  ['minifiles'] = true,
  ['minipick'] = true,
}

-- Force 'list' (when `true`) or 'nolist' (when `false`) for these.
AutoCmds.list_filetypes = {
  ['help'] = false,
  ['shellbot'] = false,
  ['TelescopePrompt'] = false,
}
--
-- Don't mess with 'conceallevel' for these.
AutoCmds.conceallevel_filetypes = {
  ['oil'] = 2,
  ['help'] = 2,
  ['markdown'] = 0,
}

-- Don't mess with numbers in these filetypes.
AutoCmds.number_blacklist = {
  ['diff'] = true,
  ['fugitiveblame'] = true,
  ['help'] = true,
  ['qf'] = true,
  ['shellbot'] = true,
  ['undotree'] = true,
  ['TelescopePrompt'] = true,
  ['minifiles'] = true,
  ['minipick'] = true,
  ['ministarter'] = true,
  ['neoterm'] = true,
}
--
-- Don't use colorcolumn when these filetypes get focus (we want them to appear
-- full-width irrespective of 'textwidth').
AutoCmds.colorcolumn_filetype_blacklist = {
  ['TelescopePrompt'] = true,
  ['diff'] = true,
  ['oil'] = true,
  ['fugitiveblame'] = true,
  ['undotree'] = true,
  ['qf'] = true,
}

AutoCmds.mkview_filetype_blacklist = {
  ['diff'] = true,
  ['gitcommit'] = true,
  ['hgcommit'] = true,
}

-- Helper ===

-- stylua: ignore
local focused_colorcolumn = '+' .. table.concat({
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
  '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23',
  '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34',
  '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45',
  '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56',
  '57', '58', '59', '60', '61', '62', '63', '64', '65', '66', '67',
  '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78',
  '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
  '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100',
  '101', '102', '103', '104', '105', '106', '107', '108', '109', '110',
  '111', '112', '113', '114', '115', '116', '117', '118', '119', '120',
  '121', '122', '123', '124', '125', '126', '127', '128', '129', '130',
  '131', '132', '133', '134', '135', '136', '137', '138', '139', '140',
  '141', '142', '143', '144', '145', '146', '147', '148', '149', '150',
  '151', '152', '153', '154', '155', '156', '157', '158', '159', '160',
  '161', '162', '163', '164', '165', '166', '167', '168', '169', '170',
  '171', '172', '173', '174', '175', '176', '177', '178', '179', '180',
  '181', '182', '183', '184', '185', '186', '187', '188', '189', '190',
  '191', '192', '193', '194', '195', '196', '197', '198', '199', '200',
  '201', '202', '203', '204', '205', '206', '207', '208', '209', '210',
  '211', '212', '213', '214', '215', '216', '217', '218', '219', '220',
  '221', '222', '223', '224', '225', '226', '227', '228', '229', '230',
  '231', '232', '233', '234', '235', '236', '237', '238', '239', '240',
  '241', '242', '243', '244', '245', '246', '247', '248', '249', '250',
  '251', '252', '253', '254'
}, ',+')

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

function H.focus_window()
  local filetype = vim.bo.filetype

  -- Turn on relative numbers
  if filetype ~= '' and AutoCmds.number_blacklist[filetype] ~= true then
    vim.wo.number = true
    vim.wo.relativenumber = true
  end

  if filetype == '' or AutoCmds.winhighlight_filetype_blacklist[filetype] ~= true then vim.wo.winhighlight = '' end

  if filetype == '' or AutoCmds.colorcolumn_filetype_blacklist[filetype] ~= true then
    vim.wo.colorcolumn = focused_colorcolumn
  end

  if filetype == '' then
    vim.wo.list = true
  else
    local list = AutoCmds.list_filetypes[filetype]
    if list == nil then
      vim.wo.list = true
    else
      vim.wo.list = list
    end
  end

  local conceallevel = AutoCmds.conceallevel_filetypes[filetype] or 2
  vim.wo.conceallevel = conceallevel
end

function H.blur_window()
  local filetype = vim.bo.filetype

  -- Turn off relative numbers (and turn on non-relative numbers)
  if filetype ~= '' and AutoCmds.number_blacklist[filetype] ~= true then
    vim.wo.number = true
    vim.wo.relativenumber = false
  end

  if filetype == '' or AutoCmds.winhighlight_filetype_blacklist[filetype] ~= true then
    vim.wo.winhighlight = winhighlight_blurred
  end

  if filetype == '' then
    vim.wo.list = false
  else
    local list = AutoCmds.list_filetypes[filetype]
    if list == nil then
      vim.wo.list = false
    else
      vim.wo.list = list
    end
  end

  if filetype == '' or AutoCmds.conceallevel_filetypes[filetype] == nil then vim.wo.conceallevel = 0 end
end

function H.should_mkview()
  return vim.bo.buftype == ''
    and AutoCmds.mkview_filetype_blacklist[vim.bo.filetype] == nil
    and vim.fn.exists('$SUDO_USER') == 0 -- Don't create root-owned files.
end

-- http://vim.wikia.com/wiki/Make_views_automatic
function H.mkview()
  if H.should_mkview() then
    local ok, err = pcall(function()
      if vim.fn.haslocaldir() == 1 then
        -- We never want to save an :lcd command, so hack around it...
        vim.cmd('cd -')
        vim.cmd('mkview')
        vim.cmd('lcd -')
      else
        vim.cmd('mkview')
      end
    end)
    if err then
      if
        err:find('%f[%w]E32%f[%W]') == nil -- No file name; could be no buffer (eg. :checkhealth)
        and err:find('%f[%w]E186%f[%W]') == nil -- No previous directory: probably a `git` operation.
        and err:find('%f[%w]E190%f[%W]') == nil -- Could be name or path length exceeding NAME_MAX or PATH_MAX.
        and err:find('%f[%w]E5108%f[%W]') == nil
      then
        error(err)
      end
    end
  end
end

function H.set_cursorline(active) vim.wo.cursorline = active end

return AutoCmds
