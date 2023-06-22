local actions = require('telescope.actions')
local lga_actions = require('telescope-live-grep-args.actions')
local builtin = require('telescope.builtin')
local slugify = require('namjul.functions.slugify')

local M = {}

function M.findFiles(args)
  args = args or {}
  local opts = {
    find_command = { 'rg', '--files', '--hidden', '--follow' },
    prompt_title = 'Files',
    previewer = false,
  }
  for k, v in pairs(args) do
    opts[k] = v
  end
  builtin.find_files(require('telescope.themes').get_ivy(opts))
end

function M.findBuffers(args)
  args = args or {}
  local opts = {
    prompt_title = 'Buffers',
    previewer = false,
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  builtin.buffers(require('telescope.themes').get_ivy(opts))
end

function M.findLspDefinitions(args)
  args = args or {}
  local opts = {
    prompt_title = 'LSP Definitions',
    previewer = true,
  }
  for k, v in pairs(args) do
    opts[k] = v
  end
  builtin.lsp_definitions(require('telescope.themes').get_ivy(opts))
end

function M.findLspReferences(args)
  args = args or {}
  local opts = {
    prompt_title = 'LSP References',
    previewer = true,
  }
  for k, v in pairs(args) do
    opts[k] = v
  end
  builtin.lsp_references(require('telescope.themes').get_ivy(opts))
end

function M.findGitFiles(args)
  args = args or {}
  local opts = {
    prompt_title = 'find git files',
  }
  for k, v in pairs(args) do
    opts[k] = v
  end
  builtin.git_files(require('telescope.themes').get_ivy(opts))
end

function M.grep_string(args)
  args = args or {}
  local opts = {
    prompt_title = 'Grep string',
  }

  for k, v in pairs(args) do
    opts[k] = v
  end

  builtin.grep_string(require('telescope.themes').get_ivy(opts))
end

function M.search(args)
  args = args or {}
  local opts = {
    auto_quoting = true,
    mappings = {
      i = {
        ['<C-k>'] = lga_actions.quote_prompt(),
        ['<C-j>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
      },
    },
  }

  for k, v in pairs(args) do
    if type(v) == 'table' and opts[k] then
      opts[k] = vim.tbl_deep_extend('force', opts[k], v)
    else
      opts[k] = v
    end
  end

  require('telescope').extensions.live_grep_args.live_grep_args(require('telescope.themes').get_ivy(opts))
end

function M.pkm()
  local search_dirs = {
    '~/Dropbox/pkm',
    '~/ghq/github.com/kevinslin/seed-tldr/vault',
  }

  M.search({
    path_display = { 'tail' },
    default_text = '"" --iglob *',
    search_dirs = search_dirs,
    mappings = {
      i = {
        -- TODO make it work with enter `<CR>`
        ['<C-x>'] = function(prompt_bufnr)
          local current_picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
          local prompt = slugify(current_picker:_get_prompt())
          local filename = search_dirs[1] .. '/' .. prompt .. '.md'

          actions.close(prompt_bufnr)
          vim.cmd('e ' .. filename)
        end,
      },
    },
  })
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
