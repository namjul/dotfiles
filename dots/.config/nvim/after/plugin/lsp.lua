local has_mason = pcall(require, 'mason')
local has_fidget = pcall(require, 'fidget')
local has_neodev = pcall(require, 'neodev')
local has_mason_lspconfig = pcall(require, 'mason-lspconfig')

if not has_mason and not has_fidget and not has_neodev and not has_mason_lspconfig then
  return
end

-- Turn on lsp status information
require('fidget').setup()

-- Setup neovim lua configuration
require('neodev').setup()

local servers = {
  rust_analyzer = {},
  tsserver = {},
  sumneko_lua = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
})

local lspconfig = require('lspconfig')

local lsp_defaults = {
  flags = {
    debounce_text_changes = 250,
  },
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  on_attach = function()
    vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
  end,
}

-- merge with lspconfig defaults
lspconfig.util.default_config = vim.tbl_deep_extend('force', lspconfig.util.default_config, lsp_defaults)

mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      settings = servers[server_name],
    })
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

--- formating and diagnostics ---

local has_null_ls = pcall(require, 'null-ls')

if not has_null_ls then
  return
end

require('null-ls').setup({
  diagnostics_format = '[#{c}] #{m} (#{s})',
  sources = {
    require('null-ls').builtins.formatting.stylua,
    require('null-ls').builtins.formatting.rustfmt,
    require('null-ls').builtins.formatting.prettierd,
    require('null-ls').builtins.diagnostics.eslint_d,
  },
})
