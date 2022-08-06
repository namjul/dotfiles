local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local inspect = vim.inspect -- pretty-print Lua objects (useful for inspecting tables)

local utils = {}

function utils.addValues(valueType, values, kind)
  kind = kind or 'options'
  local vimValue = vim[valueType]

  if type(values) == 'string' then
    return vimValue[values]
  elseif type(values) == 'table' then
    for key, value in pairs(values) do
      vimValue[key] = value
      if kind == 'options' and valueType ~= 'o' then -- util https://github.com/neovim/neovim/pull/13479 is done simulate VimScript option setting
        vim['o'][key] = value
      end
    end
  else
    error('values should be a type of "table" or "string"')
    return
  end
end

utils.opt = {
  g = function(options)
    return utils.addValues('o', options)
  end,
  b = function(options)
    return utils.addValues('bo', options)
  end,
  w = function(options)
    return utils.addValues('wo', options)
  end,
}

utils.var = {
  g = function(variables)
    return utils.addValues('g', variables, 'variables')
  end,
  w = function(variables)
    return utils.addValues('w', variables, 'variables')
  end,
  b = function(variables)
    return utils.addValues('b', variables, 'variables')
  end,
  t = function(variables)
    return utils.addValues('t', variables, 'variables')
  end,
  v = function(variables)
    return utils.addValues('v', variables, 'variables')
  end,
}

-- default to non-recursive map
local function defaultOptions(options)
  return vim.tbl_extend('force', { noremap = true }, options or {})
end

utils.map = {
  g = function(mode, lhs, rhs, options)
    vim.api.nvim_set_keymap(mode, lhs, rhs, defaultOptions(options))
  end,
  b = function(mode, lhs, rhs, options, buffer)
    buffer = buffer or 0
    vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, defaultOptions(options))
  end,
}

-- The function is called `t` for `termcodes`.
function utils.t(str)
  -- Adjust boolean arguments as needed
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function utils.createAugroup(autocmds, name)
  cmd('augroup ' .. name)
  cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
    cmd('autocmd ' .. table.concat(autocmd, ' '))
  end
  cmd('augroup END')
end

function utils.fileExists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function utils.unload_lua_namespace(prefix)
  local prefix_with_dot = prefix .. '.'
  for key, value in pairs(package.loaded) do
    if key == prefix or key:sub(1, #prefix_with_dot) == prefix_with_dot then
      package.loaded[key] = nil
    end
  end
end

function utils.shallow_merge(dest, source)
  return vim.tbl_extend('force', dest, source)
end

function utils.isVsCode()
  return vim.api.nvim_eval('exists("g:vscode")') ~= 0 and true or false
end

function utils.isNeoVide()
  return vim.api.nvim_eval('exists("g:neovide")') ~= 0 and true or false
end

return utils
