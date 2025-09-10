
-- Create listed scratch buffer and focus on it
Config.new_scratch_buffer = function() vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true)) end

-- Toggle quickfix window
Config.toggle_quickfix = function()
  local cur_tabnr = vim.fn.tabpagenr()
  for _, wininfo in ipairs(vim.fn.getwininfo()) do
    if wininfo.quickfix == 1 and wininfo.tabnr == cur_tabnr then return vim.cmd('cclose') end
  end
  vim.cmd('copen')
end

-- Log for personal use during debugging
Config.log = {}

local start_hrtime = vim.loop.hrtime()
_G.add_to_log = function(...)
  local t = { ... }
  t.timestamp = 0.000001 * (vim.loop.hrtime() - start_hrtime)
  table.insert(Config.log, vim.deepcopy(t))
end

local log_buf_id
Config.log_print = function()
  if log_buf_id == nil or not vim.api.nvim_buf_is_valid(log_buf_id) then
    log_buf_id = vim.api.nvim_create_buf(true, true)
  end
  vim.api.nvim_win_set_buf(0, log_buf_id)
  vim.api.nvim_buf_set_lines(log_buf_id, 0, -1, false, vim.split(vim.inspect(Config.log), '\n'))
end

Config.log_clear = function()
  Config.log = {}
  start_hrtime = vim.loop.hrtime()
  vim.cmd('echo "Cleared log"')
end
