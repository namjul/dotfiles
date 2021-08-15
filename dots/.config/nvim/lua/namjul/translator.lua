-- Structure from: https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua
-- and https://www.statox.fr/posts/2021/03/breaking_habits_floating_window/
-- Uses https://github.com/soimort/translate-shell
-- TODO use https://github.com/nvim-lua/popup.nvim API

local vimp = require('vimp')
local api = vim.api
local buf, win, word, language

vim.cmd('hi def link TranslatorHeader      Number')
vim.cmd('hi def link TranslatorSubHeader   Identifier')
vim.cmd('command! -nargs=* Trans lua require"namjul.translator".translate(<f-args>)')

local function open_window()

  buf = vim.api.nvim_create_buf(false, true) -- create new emtpy buffer

  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe') -- delete when hidden

  -- get dimensions
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

 -- calculate our floating window size
  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.5)

  -- and its starting position
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  -- Create the floating window
  local opts = {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = col,
    row = row,
    anchor = 'NW',
    style = 'minimal'
  }

  win = vim.api.nvim_open_win(buf, true, opts)
end

local function close_window()
  api.nvim_win_close(win, true)
end

local function update_view()
  if #word > 0 then
    local result = vim.fn.systemlist('trans --no-ansi :'..language..' '..word)

    -- with small indentation results will look better
    for k,v in pairs(result) do
      result[k] = '  '..result[k]
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)

    vim.api.nvim_buf_add_highlight(buf, -1, 'TranslatorHeader', 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, 'TranslatorSubHeader', 1, 0, -1)

    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  end
end

local function set_mappings()

  local mappings = {
    q = close_window,
    ['<Esc>'] = close_window,
    ['<CR>'] = close_window
  }

  for k,v in pairs(mappings) do
    vimp.add_buffer_maps(buf, function()
      vimp.nnoremap(k, v)
    end)
  end
end

local function translate(_language, _word)
  language = _language
  word = _word or vim.fn.expand("<cword>")

  open_window()
  set_mappings()
  update_view()
end

return {
  translate = translate,
}

