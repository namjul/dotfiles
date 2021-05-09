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
  g = function(options) return utils.addValues('o', options) end,
  b = function(options) return utils.addValues('bo', options) end,
  w = function(options) return utils.addValues('wo', options) end,
}

utils.var = {
  g = function(variables) return utils.addValues('g', variables, 'variables') end,
  w = function(variables) return utils.addValues('w', variables, 'variables') end,
  b = function(variables) return utils.addValues('b', variables, 'variables') end,
  t = function(variables) return utils.addValues('t', variables, 'variables') end,
  v = function(variables) return utils.addValues('v', variables, 'variables') end,
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

-- creates the var `paqs` for packages inspection used in `hasPlugin`
local paq_intern
local paqs = {}
function utils.paq(args)
  if type(args) == 'string' then args = {args} end
  local _, pluginName = unpack(fn.split(args[1], '/'))
  paqs[pluginName] = true
  paq_intern = paq_intern or require('paq-nvim').paq
  paq_intern(args)
end

-- check if package is active
function utils.hasPlugin(plugin)
  plugin = plugin or ''
  local lookup = fn.stdpath('data') .. '/site/pack/paqs/start/' .. plugin
  return paqs[plugin] and fn.isdirectory(lookup) ~= 0
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
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

return utils
