local dendron = require('namjul/dendron')
local Job = require('plenary/job')

local M = {}

function M.dendron(opts)
  table.insert(opts.args, '--enginePort')
  table.insert(opts.args, dendron.config.dendron_port)
  Job
    :new({
      command = 'dendron',
      args = opts.args,
      cwd = opts.dendron_dir,
      on_exit = function(j, return_val)
        -- print(return_val, 'on_exit')
        -- print(vim.inspect(j:result()))
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

function M.lookup(arg_opts, dendron_dir, json_fn)
  arg_opts['cmd'] = 'lookup'
  M.dendron({
    args = M.dendron_arg_maker(arg_opts),
    dendron_dir = dendron_dir,
    name = 'dendron lookup',
    callback = json_fn,
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

M.lookup({ query = 'hello', vault = 'wiki' }, vim.fn.expand('~/Dropbox/dendron'))
-- M.delete({ query = 'hello', vault = 'wiki' }, '~/Dropbox/dendron')

return M
