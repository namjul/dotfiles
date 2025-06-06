local lsp = {}

local signs = {
  ERROR = '✖',
  WARN = '⚐',
  INFO = '𝒾',
  HINT = '✶',
  UNKNOWN = '•',
}

lsp.init = function()

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if has_cmp_nvim_lsp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
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
  local volar_path = mason_packages .. "/vue-language-server/node_modules/@vue/language-server"
  local servers = {
    rust_analyzer = {},
    ts_ls = {
      -- single_file_support = false,
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = volar_path,
            languages = { "vue" },
          },
        },
      },
      filetypes = { "javascript", "javascript.jsx", "typescript", "typescript.tsx", "vue" }
    },
    -- marksman = {},
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            enable = true,
            globals = { 'vim' },
          },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        }
      }
    },
    volar = {},
  }

  local has_mason, mason = pcall(require, 'mason')
  local has_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if has_mason and has_mason_lspconfig then
    mason.setup()
    mason_lspconfig.setup({
      ensure_installed = vim.tbl_keys(servers),
    })
  end

  local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
  if has_mason_lspconfig and has_lspconfig then

    local lsp_defaults = {
      flags = {
        debounce_text_changes = 250,
      },
      on_attach = function(_, bufnr)
        vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached', data = { bufnr = bufnr } })
      end,
    }

    -- merge with lspconfig defaults
    lspconfig.util.default_config = vim.tbl_deep_extend('force', lspconfig.util.default_config, lsp_defaults)

    mason_lspconfig.setup_handlers({
      function(server_name)
        local opts = servers[server_name] or {}
        opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, opts.capabilities or {})
        lspconfig[server_name].setup(opts)
      end,
    })

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
