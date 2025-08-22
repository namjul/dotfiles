local lsp = {}

local signs = {
  ERROR = '✖',
  WARN = '⚐',
  INFO = '𝒾',
  HINT = '✶',
  UNKNOWN = '•',
}


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
          lineFoldingOnly = true
        }
      }
    })
  end

  vim.diagnostic.config({
    float = {
      header = 'Diagnostics', -- Default is "Diagnostics:"
      prefix = function(diagnostic, i, total)
        if diagnostic.severity == vim.diagnostic.severity.ERROR then
          return (signs.ERROR .. ' '), ''
        elseif diagnostic.severity == vim.diagnostic.severity.HINT then
          return (signs.HINT .. ' '), ''
        elseif diagnostic.severity == vim.diagnostic.severity.INFO then
          return (signs.INFO .. ' '), ''
        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
          return (signs.WARN .. ' '), ''
        else
          return (signs.UNKNOWN .. ' '), ''
        end
      end,
    },

    severity_sort = true,

    -- See also: https://github.com/neovim/nvim-lspconfig/wiki/UI-customization#change-diagnostic-symbols-in-the-sign-column-gutter
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = signs.ERROR,
        [vim.diagnostic.severity.HINT] = signs.HINT,
        [vim.diagnostic.severity.INFO] = signs.INFO,
        [vim.diagnostic.severity.WARN] = signs.WARN,
      },
      texthl = {
        [vim.diagnostic.severity.ERROR] = '',
        [vim.diagnostic.severity.HINT] = '',
        [vim.diagnostic.severity.INFO] = '',
        [vim.diagnostic.severity.WARN] = '',
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
        [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
        [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
      },
    },

    -- virtual_text = true,
    virtual_text = {
      spacing = 2,
      source = 'always',
      prefix = '',
    },
  })

  -- Turn on lsp status information
  local has_fidget, fidget = pcall(require, 'fidget')
  if has_fidget then
    fidget.setup()
  end

  local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
  local vue_language_server_path = mason_packages .. "/vue-language-server/node_modules/@vue/language-server"

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
        }
      }
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
      filetypes = { "javascript", "javascript.jsx", "typescript", "typescript.tsx", "vue" } -- TODO currently only working with *.vue files
    },
    vue_ls = {},
  }

  local ensure_installed = vim.tbl_keys(servers or {})

  local has_mason, mason = pcall(require, 'mason')
  if has_mason then
    mason.setup()
  end

  local has_mason_tool_installer, mason_tool_installer = pcall(require, 'mason-tool-installer')
  if has_mason_tool_installer then
    mason_tool_installer.setup { ensure_installed = ensure_installed }
  end

  local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
  local has_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if has_mason and has_mason_lspconfig and has_lspconfig then

    mason_lspconfig.setup({
      ensure_installed = {}, -- explicitly set to an empty table (populated installs via mason-tool-installer)
      automatic_enable = true
    })

    for server_name, server_config in pairs(servers) do
      server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
      vim.lsp.config(server_name, server_config)
    end

    vim.lsp.enable({ 'vue_ls', 'vtsls', 'lua_ls' })
  end

  --- formating and diagnostics ---
  local has_null_ls, null_ls = pcall(require, 'null-ls')
  if has_null_ls then
    null_ls.setup({
      diagnostics_format = '[#{c}] #{m} (#{s})',
      sources = {
        -- TODO load when available
        null_ls.builtins.formatting.stylua,
        require("none-ls.diagnostics.eslint_d")
      },
    })
  end


end

return lsp
