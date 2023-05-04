local has_telescope = pcall(require, 'telescope')

if not has_telescope then
  return
end

local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    prompt_prefix = ' ',
    mappings = { -- https://github.com/nvim-telescope/telescope.nvim#default-mappings
      i = {
        ['<esc>'] = actions.close,
        ['<C-q>'] = actions.send_to_qflist,
        ['<M-p>'] = require('telescope.actions.layout').toggle_preview,
      },
    },
  },
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
