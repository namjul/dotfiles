local mason_packages = vim.fn.stdpath('data') .. '/mason/packages'
local vue_language_server_path = mason_packages .. '/vue-language-server/node_modules/@vue/language-server'

local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}

---@type vim.lsp.Config
return {
  settings = {
    -- see config schema: https://raw.githubusercontent.com/yioneko/vtsls/refs/heads/main/packages/service/configuration.schema.json
    typescript = { tsserver = { maxTsServerMemory = 16184 } },
    javascript = { tsserver = { maxTsServerMemory = 16184 } },
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      'package-lock.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'bun.lockb',
      'bun.lock',
      'aube-lock.yaml',
    }
    local project_root = vim.fs.root(bufnr, root_markers)
    if project_root then on_dir(project_root) end
  end,
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
  },
}
