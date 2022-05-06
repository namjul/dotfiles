require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = {
    'tsx',
    'typescript',
    'javascript',
    'toml',
    'fish',
    'bash',
    'php',
    'json',
    'graphql',
    'yaml',
    'html',
    'lua',
    'scss',
    'css',
  },
  autotag = {
    enable = true,
  },
})
