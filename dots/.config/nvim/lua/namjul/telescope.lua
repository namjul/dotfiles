local M = {}

function M.findFiles(args)
  args = args or {}
  local opts = {
    find_command = { 'rg', '--files' },
    prompt_title = '< VimRC >',
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  -- require('telescope').extensions.fzf_writer.files({
  require('telescope.builtin').find_files(opts)
end

function M.searchDotfiles()
  M.findFiles({ cwd = '~/.dotfiles' })
end

return M
