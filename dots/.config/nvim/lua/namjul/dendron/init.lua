local utils = require('namjul/dendron/utils')
local context_manager = require('plenary/context_manager')
local Job = require('plenary/job')

local uv = vim.loop
local with = context_manager.with
local open = context_manager.open

--[[ references
  - https://github.com/oberblastmeister/neuron.nvim/blob/master/lua/neuron.lua
--]]

local M = {}

function M.start_engine(opts)
  assert(not DendronJob, 'you already started a neuron server')

  DendronJob = Job
    :new({
      command = 'dendron',
      args = { 'launchEngineServer', '--init', '--port', opts.port },
      cwd = opts.dendron_dir,
      on_exit = function(_, data)
        print(data .. ' on_exit')
      end,
      on_stdout = function(_, data)
        print(data .. ' on_stdout')
      end,
      on_stderr = utils.on_stderr_factory(opts.name),
    })
    :start()

  vim.cmd([[
      augroup DendronJobStop
      autocmd!
      au VimLeave * lua require'namjul.dendron'.stop()
      augroup END
    ]])

  if opts.verbose then
    print('Started dendron server at' .. opts.port)
  end
end

function M.stop()
  if DendronJob ~= nil then
    DendronJob:shutdown()
    DendronJob = nil
  end
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

  user_config = user_config or {}

  -- create M.config for external reference
  M.config = vim.tbl_extend('force', default_config, user_config)

  -- expand dendron directory
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

  -- check if dendron engine is already running and start if not
  Job
    :new({
      command = 'lsof',
      args = { '-i:' .. dendron_port },
      on_exit = vim.schedule_wrap(function(_, data)
        print('Start Dendron Engine: ' .. data)
        if data == 1 then
          -- start engine
          M.start_engine({ port = dendron_port, dendron_dir = M.config.dendron_dir, verbose = true })
        end
      end),
    })
    :start()
end

return M
