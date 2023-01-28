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
  indent = {
    enable = true,
  },
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
  },

  -- enables https://github.com/windwp/nvim-ts-autotag
  autotag = {
    enable = true,
  }
})
