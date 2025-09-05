
-- Plugins requiring settings to exist
vim.g.winresizer_start_key = '<S-T>'
vim.g.VimuxOrientation = 'h'
vim.g.switch_mapping = ''
vim.g.markdown_composer_open_browser = 0

namjul.lsp.init()

-- require('clipboard-image').setup({
--   default = {
--     img_name = function()
--       vim.fn.inputsave()
--       local name = vim.fn.input('Name: ')
--       vim.fn.inputrestore()
--       return name
--     end,
--     img_dir = { '%:p:h', 'assets', 'images' },
--     img_dir_txt = './assets/images',
--   },
-- })

require('namjul.translator')

require('pastify').setup({
  opts = {
    absolute_path = false, -- use absolute or relative path to the working directory
    local_path = './assets/images', -- The path to put local files in, ex <cwd>/assets/images/<filename>.png
    save = 'local', -- Either 'local' or 'online' or 'local_file'
    filename = function()
      vim.fn.inputsave()
      local name = vim.fn.input('Name: ')
      vim.fn.inputrestore()
      return name
    end,
    default_ft = 'markdown', -- Default filetype to use
  },
})

require('glow').setup()
require('oil').setup({
  keymaps = {
    ['<C-p>'] = 'actions.copy_entry_path',
    -- Scope files lookup by current working directory
    ['<leader>ff'] = {
      function()
        namjul.functions.telescope.findFiles({
          cwd = require('oil').get_current_dir(),
        })
      end,
      mode = 'n',
      nowait = true,
      desc = 'Find files in the current directory',
    },
    ['<leader>:'] = {
      'actions.open_cmdline',
      opts = {
        shorten_path = true,
        modify = ':h',
      },
      desc = 'Open the command line with the current directory as an argument',
    },
  },
  delete_to_trash = true,
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    -- natural_order = true,
    is_always_hidden = function(name)
      return name == '..' or name == '.git'
    end
  }
})
require('hlargs').setup()

require('conform').setup({
  notify_on_error = false,
  format_on_save = false,
  formatters_by_ft = {
    lua = { 'stylua' },
    -- Conform will run multiple formatters sequentially
    -- python = { 'isort', 'black' },
    -- Use a sub-list to run only the first available formatter
    javascript = { { 'prettierd', 'prettier' } },
    typescript = { { 'prettierd', 'prettier' } },
  },
})

require('mini.diff').setup({
  view = {
    style = 'sign',
  }
})
require('mini.surround').setup({
  mappings = {
    add = 'sa', -- Add surrounding in Normal and Visual modes
    delete = 'sd', -- Delete surrounding
    find = 'sf', -- Find surrounding (to the right)
    find_left = 'sF', -- Find surrounding (to the left)
    highlight = 'sh', -- Highlight surrounding
    replace = 'sr', -- Replace surrounding
    update_n_lines = 'sn', -- Update `n_lines`
    suffix_last = 'l', -- Suffix to search with "prev" method
    suffix_next = 'n', -- Suffix to search with "next" method
  },
})
require('mini.indentscope').setup()
require('mini.ai').setup()
require('mini.pairs').setup()
require('mini.trailspace').setup()
require('mini.icons').setup()
require('mini.statusline').setup()
require('mini.operators').setup({ replace = { prefix = '<leader>r' }})
require('mini.tabline').setup({
  tabpage_section = 'right'
})
require('mini.jump').setup()

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    fixme = { pattern = '[Xx][Xx][Xx]', group = 'MiniHipatternsFixme' },
    hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
    todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
    note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require('mini.notify').setup()
vim.notify = require('mini.notify').make_notify()

require('harpoon').setup()

require('blink.cmp').setup({
  snippets = { preset = 'luasnip' },
  keymap = {
    preset = 'none',
    ['<C-o>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },

    ['<Tab>'] = { 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },
  sources = {
    providers = {
      snippets = {
        score_offset = 10
      }
    }
  }
})

namjul.plugin.lazy('nvim-tree.lua', {
  afterload = function()
    require('nvim-tree').setup({
      actions = {
        open_file = {
          window_picker = { enable = false }
        },
      },
      renderer = {
        indent_markers = {
          enable = true
        },
        icons = {
          show = {
            git = false,
            folder = false,
            folder_arrow = false,
          }
        },
        special_files = {
          enable = false
        }
      },
      git = {
        enable = false,
      },
    })
  end,
  commands = {
    'NvimTreeFindFile',
    'NvimTreeToggle',
    'NvimTreeOpen',
  },
  keymap = {
    { 'n', '<LocalLeader>f', ':NvimTreeFindFile<CR>', { silent = true } },
    { 'n', '<LocalLeader>t', ':NvimTreeToggle<CR>', { silent = true } },
  },
})

namjul.plugin.lazy('notmuch', {
  afterload = function()
    require('notmuch').setup({
      notmuch_db_path = "/home/hobl/.mail"
    })
  end,
  commands = {
    'Notmuch',
  }
})

namjul.plugin.lazy('overseer', {
  afterload = function()
    require('overseer').setup()
  end,
  commands = {
    'OverseerRun',
    'OverseerOpen',
    'OverseerToggle',
  },
  keymap = {
    { 'n', '<Leader>t', ':OverseerToggle<CR>', { silent = true } },
  },
})

namjul.plugin.lazy('undotree', {
  beforeload = function()
    vim.g.undotree_HighlightChangedText = 0
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_DiffCommand = 'diff -u'
  end,
  keymap = {
      { 'n', '<Leader>u', ':UndotreeToggle<CR>', { silent = true } },
    },
})

require('nvim-ts-autotag').setup()

namjul.plugin.load('shellbot')
