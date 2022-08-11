local M = {}

function M.findFiles(args)
  args = args or {}
  local opts = {
    find_command = { 'rg', '--files' },
    prompt_title = 'find files',
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').find_files(require('telescope.themes').get_ivy(opts))
end

function M.findMostWanted(args)
  args = args or {}
  local opts = {
    find_command = { 'most-wanted-dirs' },
    prompt_title = 'Most wanted dirs',
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').find_files(require('telescope.themes').get_ivy(opts))
end

function M.findRecent(args)
  args = args or {}
  local opts = {
    prompt_title = 'find recent files',
    include_current_session = true,
    -- cwd_only = true
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy(opts))
end

function M.searchDotfiles()
  M.findFiles({ cwd = '~/.dotfiles' })
end

return M
