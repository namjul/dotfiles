local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')

local M = {}

function M.addValues(valueType, values, kind)
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

M.opt = {
  g = function(options) return M.addValues('o', options) end,
  b = function(options) return M.addValues('bo', options) end,
  w = function(options) return M.addValues('wo', options) end,
}

M.var = {
  g = function(variables) return M.addValues('g', variables, 'variables') end,
  w = function(variables) return M.addValues('w', variables, 'variables') end,
  b = function(variables) return M.addValues('b', variables, 'variables') end,
  t = function(variables) return M.addValues('t', variables, 'variables') end,
  v = function(variables) return M.addValues('v', variables, 'variables') end,
}

-- default to non-recursive map
local function defaultOptions(options) return vim.tbl_extend('force', { noremap = true }, options or {}) end

M.map = {
  g = function(mode, lhs, rhs, options) vim.api.nvim_set_keymap(mode, lhs, rhs, defaultOptions(options)) end,
  b = function(mode, lhs, rhs, options, buffer)
    buffer = buffer or 0
    vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, defaultOptions(options))
  end,
}

function M.termcodes(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

function M.createAugroup(autocmds, name)
  cmd('augroup ' .. name)
  cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
    cmd('autocmd ' .. table.concat(autocmd, ' '))
  end
  cmd('augroup END')
end

function M.fileExists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.unload_lua_namespace(prefix)
  local prefix_with_dot = prefix .. '.'
  for key, _ in pairs(package.loaded) do
    if key == prefix or key:sub(1, #prefix_with_dot) == prefix_with_dot then package.loaded[key] = nil end
  end
end

function M.shallow_merge(dest, source) return vim.tbl_extend('force', dest, source) end

function M.isVsCode() return vim.api.nvim_eval('exists("g:vscode")') ~= 0 and true or false end

function M.isNeoVide() return vim.api.nvim_eval('exists("g:neovide")') ~= 0 and true or false end

function M.readable(file_path) return vim.fn.filereadable(file_path) ~= 0 end

function M.is_directory(file_path) return vim.fn.isdirectory(file_path) ~= 0 end

-- from https://github.com/wincent/wincent/blob/b0a88e810481b0be31218eb1aa37104ce4874ee0/aspects/nvim/files/.config/nvim/lua/wincent/plugin/load.lua
function M.loadPlugin(plugin)
  if vim.v.vim_did_enter == 1 then
    -- Modifies 'runtimepath' _and_ sources files.
    vim.cmd('packadd ' .. plugin)
  else
    -- Just modifies 'runtimepath'; Vim will source the files later as part of
    -- |load-plugins| process.
    vim.cmd('packadd! ' .. plugin)
  end
end

return M
