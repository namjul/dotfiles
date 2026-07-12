local M = {}

local PULSE_SEQUENCE = {
  { fg = '#fabd2f', bold = true },
  { fg = '#fe8019', bold = true },
  { fg = '#fbf1c7', bold = true },
  { fg = '#fabd2f', bold = true },
  { fg = '#fe8019', bold = true },
  { fg = '#fbf1c7', bold = true },
  { fg = '#fabd2f', bold = true },
  { fg = '#fe8019', bold = true },
}

local function setup_highlights()
  vim.api.nvim_set_hl(0, 'Write750Running', { fg = '#928374' })
  vim.api.nvim_set_hl(0, 'Write750GoalMet', { fg = '#61afef', bold = true })
  vim.api.nvim_set_hl(0, 'Write750Done', { fg = '#b8bb26', bold = true })
  vim.api.nvim_set_hl(0, 'Write750Over', { fg = '#8ec07c', bold = true })
  vim.api.nvim_set_hl(0, 'Write750Pulse', { fg = '#fabd2f', bold = true })
end

local function count_words(buf)
  local count = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 1, -1, false)) do
    for _ in line:gmatch('%S+') do
      count = count + 1
    end
  end
  return count
end

local function format_time(seconds) return string.format('%02d:%02d', math.floor(seconds / 60), seconds % 60) end

local function set_winbar(win, words, seconds, highlight)
  if not vim.api.nvim_win_is_valid(win) then return end
  vim.wo[win].winbar = string.format('%%=%%#%s# %d words • %s ', highlight, words, format_time(seconds))
end

local function set_winbar_idle(win)
  if not vim.api.nvim_win_is_valid(win) then return end
  vim.wo[win].winbar = '%=%#Write750Running# 0 words '
end

local function date_string() return os.date('%Y.%m.%d') end

local function save_directory() return vim.fn.expand(vim.g.write750_save_dir or '~/Dropbox/memex/') end

local function do_save(lines, path)
  local content = table.concat(lines, '\n') .. '\n'
  local dir = vim.fn.fnamemodify(path, ':h')
  if vim.fn.mkdir(dir, 'p') == 0 then
    vim.notify('750words: cannot create directory ' .. dir, vim.log.levels.ERROR)
    return
  end
  -- check existence before open so the separator is correct (open with 'a' always creates)
  local exists = vim.uv.fs_stat(path) ~= nil
  local out, err = io.open(path, 'a')
  if not out then
    vim.notify('750words: cannot open file — ' .. (err or path), vim.log.levels.ERROR)
    return
  end
  out:write((exists and '\n---\n\n' or '') .. content)
  out:close()
  vim.notify('Saved → ' .. path)
end

function M.start(opts)
  opts = opts or {}
  local max_words = opts.max_words or 750
  local max_time = opts.max_time or 600

  setup_highlights()

  Config.new_scratch_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  -- acwrite: BufWriteCmd intercepts :w; modified=true blocks :q (unlike nofile)
  -- Buffer needs a name so :w doesn't fail with E32 before BufWriteCmd fires
  vim.api.nvim_buf_set_name(buf, '750words')
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].bufhidden = 'wipe'

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '# ' .. date_string() .. ' ', '' })
  vim.api.nvim_win_set_cursor(win, { 2, 0 })
  vim.cmd('startinsert')
  -- reset modified flag set by buf_set_lines so :q is clean until user types
  vim.bo[buf].modified = false

  set_winbar_idle(win)

  local state = {
    timer = nil,
    pulse_timer = nil,
    start_time = nil,
    word_count = 0,
    prev_word_goal_met = false,
    pulsing = false,
    ready = false,
  }

  local augroup = vim.api.nvim_create_augroup('Write750_' .. buf, { clear = true })

  local function get_win()
    local cur = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(cur) == buf then return cur end
    local w = vim.fn.bufwinid(buf)
    return w ~= -1 and w or nil
  end

  local function start_pulse()
    state.pulsing = true
    local step = 0
    state.pulse_timer = vim.uv.new_timer()
    state.pulse_timer:start(
      0,
      120,
      vim.schedule_wrap(function()
        step = step + 1
        local target_win = get_win()
        if step > #PULSE_SEQUENCE or not target_win then
          state.pulse_timer:stop()
          state.pulse_timer:close()
          state.pulse_timer = nil
          state.pulsing = false
          return
        end
        vim.api.nvim_set_hl(0, 'Write750Pulse', PULSE_SEQUENCE[step])
        local elapsed = (vim.uv.now() - state.start_time) / 1000
        vim.wo[target_win].winbar =
          string.format('%%=%%#Write750Pulse# %d words • %s ', state.word_count, format_time(math.floor(elapsed)))
      end)
    )
  end

  local function tick()
    if not vim.api.nvim_buf_is_valid(buf) then
      if state.timer then
        state.timer:stop()
        state.timer:close()
        state.timer = nil
      end
      return
    end
    local current_win = get_win()
    -- buffer alive but hidden in another tab: keep the timer running, skip the redraw
    if not current_win then return end
    if state.pulsing then return end

    local words = count_words(buf)
    state.word_count = words
    local elapsed = (vim.uv.now() - state.start_time) / 1000
    local seconds = math.floor(elapsed)
    local word_goal_met = words >= max_words
    local time_limit_met = elapsed >= max_time

    if word_goal_met and time_limit_met then
      set_winbar(current_win, words, seconds, 'Write750Done')
      return
    end

    if word_goal_met and not state.prev_word_goal_met then start_pulse() end
    state.prev_word_goal_met = word_goal_met

    if time_limit_met and not word_goal_met then
      set_winbar(current_win, words, seconds, 'Write750Over')
      return
    end

    set_winbar(current_win, words, seconds, word_goal_met and 'Write750GoalMet' or 'Write750Running')
  end

  -- Defer so buf_set_lines/startinsert events don't fire the timer
  vim.schedule(function() state.ready = true end)

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = augroup,
    buffer = buf,
    callback = function()
      if not state.ready then return end
      if state.start_time ~= nil then return end
      state.start_time = vim.uv.now()
      state.timer = vim.uv.new_timer()
      state.timer:start(0, 250, vim.schedule_wrap(tick))
    end,
  })

  -- Notify on :q so the user knows what to do; E37 from acwrite+modified does the blocking
  vim.api.nvim_create_autocmd('QuitPre', {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_buf() ~= buf then return end
      if not vim.bo[buf].modified then return end
      -- other windows still hold the buffer: closing this one won't abandon it, so don't warn
      if #vim.fn.win_findbuf(buf) > 1 then return end
      vim.notify('Writing session unsaved — :w to save, :q! to discard', vim.log.levels.WARN)
    end,
  })

  -- Intercepts :w for acwrite buffers; handles the actual write
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    group = augroup,
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local has_content = false
      for i = 2, #lines do
        if lines[i]:match('%S') then
          has_content = true
          break
        end
      end
      if not has_content then
        vim.bo[buf].modified = false
        return
      end
      do_save(lines, save_directory() .. 'daily.journal.' .. date_string() .. '.md')
      vim.bo[buf].modified = false
    end,
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = augroup,
    buffer = buf,
    once = true,
    callback = function()
      if state.timer then
        state.timer:stop()
        state.timer:close()
        state.timer = nil
      end
      if state.pulse_timer then
        state.pulse_timer:stop()
        state.pulse_timer:close()
        state.pulse_timer = nil
      end
    end,
  })
end

return M
