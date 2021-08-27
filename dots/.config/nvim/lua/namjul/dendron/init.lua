--[[ references
  - https://github.com/oberblastmeister/neuron.nvim/blob/master/lua/neuron.lua
--]]

local M = {}

function M.setup(user_config)
  local default_config = {
    neuron_dir = '~/dendron',
    -- virtual_titles = true, -- set virtual titles
    -- mappings = true, -- to set default mappings
    -- run = nil, -- custom code to run
    -- leader = 'gz', -- the leader key to for all mappings
  }

  if vim.fn.executable('dendron') == 0 then
    error('dendron is not executable')
  end

  local user_config = user_config or {}
  M.config = vim.tbl_extend('keep', user_config, default_config)
  M.config.neuron_dir = vim.fn.expand(M.config.neuron_dir)
end

return M
