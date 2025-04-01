
-- from https://github.com/wincent/wincent/blob/e6fcae494c9fda25b2aa9c76941585d4eb3a97e3/aspects/nvim/files/.config/nvim/lua/wincent/plugin/load.lua
local load = function(plugin)
  if vim.v.vim_did_enter == 1 then
    -- Modifies 'runtimepath' _and_ sources files.
    vim.cmd('packadd ' .. plugin)
  else
    -- Just modifies 'runtimepath'; Vim will source the files later as part of
    -- |load-plugins| process.
    vim.cmd('packadd! ' .. plugin)
  end
end

return load
