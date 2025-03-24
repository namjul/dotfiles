local lsp = {}


lsp.init = function()

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if has_cmp_nvim_lsp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

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
      filetypes = {
        "javascript",
        "typescript",
        "vue",
      },
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

    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = {
        spacing = 2,
        source = 'always',
        prefix = '',
      },
      underline = true,
      signs = true,
    })

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {})

    vim.cmd([[
  sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=LspDiagnosticsDefaultError
  sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=LspDiagnosticsDefaultWarning
  sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=LspDiagnosticsDefaultInformation
  sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=LspDiagnosticsDefaultInformation
]])

  end

  --- formating and diagnostics ---
  local has_none_ls, none_ls = pcall(require, 'none-ls')
  if has_none_ls then
    none_ls.setup({
      diagnostics_format = '[#{c}] #{m} (#{s})',
      sources = {
        -- TODO load when available
        require('none-ls').builtins.formatting.stylua,
        require('none-ls').diagnostics.eslint_d,
      },
    })
  end


end

return lsp
