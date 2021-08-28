local utils = require('namjul/dendron/utils')
local context_manager = require('plenary/context_manager')
local Job = require('plenary/job')

local with = context_manager.with
local open = context_manager.open

--[[ references
  - https://github.com/oberblastmeister/neuron.nvim/blob/master/lua/neuron.lua
--]]

local M = {}

function M.start_engine(opts)
  Job
    :new({
      command = 'dendron',
      args = { 'launchEngineServer', '--init', '--port', opts.port },
      cwd = opts.dendron_dir,
      on_exit = function(j, return_val)
        print(return_val, 'on_exit')
        print(vim.inspect(j:result()))
      end,
      on_stdout = function(j, return_val)
        print(return_val, 'on_stdout')
        -- print(vim.inspect(j:result()))
      end,
      on_stderr = function(j, return_val)
        print(return_val, 'on_stderr')
        -- print(vim.inspect(j:result()))
      end,
    })
    :start()
end

function M.setup(user_config)
  local default_config = {
    dendron_dir = '~/dendron',
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
  M.config.dendron_dir = vim.fn.expand(M.config.dendron_dir)

  -- local dendron_config_file = vim.fn.expand(M.config.dendron_dir .. '/dendron.yml')
  local dendron_port_file = vim.fn.expand(M.config.dendron_dir .. '/.dendron.port')

  local dendron_port = 3005

  if utils.file_exists(dendron_port_file) then
    dendron_port = with(open(dendron_port_file), function(reader)
      return reader:read()
    end)
  end

  M.config.dendron_port = dendron_port

  -- check if dendron engine is already running
  Job
    :new({
      command = 'lsof',
      args = { '-i:' .. dendron_port },
      on_exit = function(j, return_val)
        if return_val == 1 then
          -- start engine
          M.start_engine({ port = dendron_port, dendron_dir = M.config.dendron_di })
        end
      end,
    })
    :start()
end

M.setup({ dendron_dir = '~/Dropbox/dendron' })

return M
