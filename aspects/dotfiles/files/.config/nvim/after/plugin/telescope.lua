local has_telescope = pcall(require, 'telescope')
local has_lga_telescope = pcall(require, 'telescope-live-grep-args.actions')

if not has_telescope and not has_lga_telescope then
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
        ['<C-x>'] = false,
        ['<C-s>'] = actions.select_horizontal,
        ['<M-p>'] = require('telescope.actions.layout').toggle_preview,
      },
      n = {
        ['<C-x>'] = false,
        ['<C-s>'] = actions.select_horizontal,
      },
    },
  },
   extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_ivy {
        prompt_title = 'Select',
      }
    }
  }
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
