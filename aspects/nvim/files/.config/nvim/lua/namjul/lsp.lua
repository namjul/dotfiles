local lsp = {}

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached', data = { bufnr = bufnr } })
  end,
})

lsp.init = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local has_blink = pcall(require, 'blink.cmp')
  if has_blink then
    capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))
    capabilities = vim.tbl_deep_extend('force', capabilities, {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    })
  end

  local mason_packages = vim.fn.stdpath('data') .. '/mason/packages'
  local vue_language_server_path = mason_packages .. '/vue-language-server/node_modules/@vue/language-server'

  local vue_plugin = {
    name = '@vue/typescript-plugin',
    location = vue_language_server_path,
    languages = { 'vue' },
    configNamespace = 'typescript',
  }

  local servers = {
    rust_analyzer = {},
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            enable = true,
            globals = { 'vim' },
          },
          workspace = { checkthirdparty = false },
          telemetry = { enable = false },
        },
      },
    },
    vtsls = {
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
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'vue',
      },
    },
    vue_ls = {},
  }

  local ensure_installed = vim.tbl_keys(servers or {})

  local has_mason, mason = pcall(require, 'mason')
  if has_mason then mason.setup() end

  local has_mason_tool_installer, mason_tool_installer = pcall(require, 'mason-tool-installer')
  if has_mason_tool_installer then mason_tool_installer.setup({ ensure_installed = ensure_installed }) end

  local has_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if has_mason and has_mason_lspconfig then
    for server_name, server_config in pairs(servers) do
      server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
      vim.lsp.config(server_name, server_config)
    end

    mason_lspconfig.setup({
      ensure_installed = {}, -- explicitly set to an empty table (populated installs via mason-tool-installer)
      automatic_enable = true,
    })
  end
end

return lsp
