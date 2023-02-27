local M = {}

function M.findFiles(args)
  args = args or {}
  local opts = {
    find_command = { 'rg', '--files', '--hidden', '--follow' },
    prompt_title = 'find files',
    previewer = false,
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').find_files(require('telescope.themes').get_ivy(opts))
end

function M.findGitFiles(args)
  args = args or {}
  local opts = {
    prompt_title = 'find git files',
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').git_files(require('telescope.themes').get_ivy(opts))
end

function M.grep_string(args)
  args = args or {}
  local opts = {
    prompt_title = 'Grep string',
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').grep_string(require('telescope.themes').get_ivy(opts))
end

function M.live_grep(args)
  args = args or {}
  local opts = {
    prompt_title = 'Live grep',
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').live_grep(require('telescope.themes').get_ivy(opts))
end

function M.find_most_wanted(args)
  args = args or {}
  local opts = {
    find_command = { 'most-wanted-dirs' },
    prompt_title = 'Most wanted dirs',
    previewer = false,
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').find_files(require('telescope.themes').get_ivy(opts))
end

function M.find_recent(args)
  args = args or {}
  local opts = {
    prompt_title = 'find recent files',
    include_current_session = true,
    previewer = false,
    -- cwd_only = true
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy(opts))
end

function M.search_dotfiles()
  M.findFiles({ cwd = '~/.dotfiles' })
end

return M
