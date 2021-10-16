local dendron = require('namjul/dendron')
local utils = require('namjul/dendron/utils')
local Job = require('plenary/job')

local M = {}

function M.dendron(opts)
  table.insert(opts.args, '--enginePort')
  table.insert(opts.args, dendron.config.dendron_port)

  local result = ''

  Job
    :new({
      command = 'dendron',
      args = opts.args,
      cwd = opts.dendron_dir,
      on_exit = vim.schedule_wrap(function()
        opts.callback(opts.json and vim.fn.json_decode(result) or result)
      end),
      on_stdout = vim.schedule_wrap(function(error, data)
        assert(not error, error)
        result = result .. data
      end),
      on_stderr = utils.on_stderr_factory(opts.name),
    })
    :start()
end

function M.lookup(arg_opts, dendron_dir, json_fn)
  arg_opts['cmd'] = 'lookup'
  M.dendron({
    args = M.dendron_arg_maker(arg_opts),
    dendron_dir = dendron_dir,
    name = 'dendron lookup',
    callback = json_fn,
    json = true,
  })
end

function M.delete(arg_opts, dendron_dir, json_fn)
  arg_opts['cmd'] = 'delete'
  M.dendron({
    args = M.dendron_arg_maker(arg_opts),
    dendron_dir = dendron_dir,
    name = 'dendron delete',
    callback = json_fn,
  })
end

function M.dendron_arg_maker(opts)
  local args = { 'note' }

  if opts.cmd then
    table.insert(args, opts.cmd)
  end

  if opts.query then
    table.insert(args, '--query')
    table.insert(args, opts.query)
  end

  if opts.vault then
    table.insert(args, '--vault')
    table.insert(args, opts.vault)
  end

  return args
end

return M
