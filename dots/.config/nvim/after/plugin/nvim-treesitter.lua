local has_nvim_treesitter = pcall(require, 'nvim-treesitter')

if not has_nvim_treesitter then
  return
end

require('nvim-treesitter.configs').setup({

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  -- Indentation based on treesitter for the = operator. NOTE: This is an experimental feature.
  indent = { enable = true, disable = { 'python' } },
  ensure_installed = {
    'help',
    'tsx',
    'typescript',
    'javascript',
    'toml',
    'fish',
    'markdown',
    'bash',
    'rust',
    'php',
    'json',
    'http',
    'graphql',
    'yaml',
    'html',
    'lua',
    'scss',
    'css',
    'glimmer',
    'mermaid'
  },

  -- enables https://github.com/windwp/nvim-ts-autotag
  autotag = {
    enable = true,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-m>',
      node_incremental = '<c-m>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-n>',
    },
    -- fix from https://github.com/nvim-treesitter/nvim-treesitter/issues/2634#issuecomment-1362479800
    is_supported = function()
      local ct = vim.fn.getcmdwintype()
      if ct ~= '' then
        return false
      end
      return true
    end,
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
})

local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
ft_to_parser.mdx = "markdown"
