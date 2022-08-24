local has_nvim_treesitter = pcall(require, 'nvim-treesitter')

if not has_nvim_treesitter then
  return
end

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
    'markdown',
    'bash',
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
  autotag = {
    enable = true,
  },
})
