local has_lspconfig = pcall(require, 'lspconfig')

if not has_lspconfig then
  return
end

local lspconfig = require('lspconfig')

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

local lsp_defaults = {
  flags = {
    debounce_text_changes = 250,
  },
  -- capabilities = require('cmp_nvim_lsp').update_capabilities(
  --   vim.lsp.protocol.make_client_capabilities()
  -- ),
  on_attach = function()
    vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
  end,
}

-- merge with lspconfig defaults
lspconfig.util.default_config = vim.tbl_deep_extend('force', lspconfig.util.default_config, lsp_defaults)

--- setup typescript lsp ---

lspconfig.tsserver.setup({
  -- capabilities = capabilities,
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
})

--- setup lua lsp ---

local cmd = nil

if vim.fn.has('unix') == 1 then
  cmd = vim.fn.expand('~/local/lua-language-server/bin/lua-language-server')
  if vim.fn.executable(cmd) == 1 then
    cmd = { cmd, '-E', vim.fn.expand('~/local/lua-language-server/main.lua') }
  else
    cmd = nil
  end
else
  cmd = 'lua-language-server'
  if vim.fn.executable(cmd) == 1 then
    cmd = { cmd }
  else
    cmd = nil
  end
end

if cmd ~= nil then
  lspconfig.sumneko_lua.setup({
    cmd = cmd,
    settings = {
      Lua = {
        diagnostics = {
          enable = true,
          globals = { 'vim' },
        },
        filetypes = { 'lua' },
        runtime = {
          path = vim.split(package.path, ';'),
          version = 'LuaJIT',
        },
      },
    },
  })
end

--- setup rust lsp ---

lspconfig['rust_analyzer'].setup({
  -- Server-specific settings...
  settings = {
    ['rust-analyzer'] = {},
  },
})

--- formating and diagnostics ---

local has_null_ls = pcall(require, 'null-ls')

if not has_null_ls then
  return
end

require('null-ls').setup({
  root_dir = function(fname)
    return lspconfig.util.root_pattern('.git', 'dendron.yml')(fname)
  end,
  diagnostics_format = '[#{c}] #{m} (#{s})',
  sources = {
    require('null-ls').builtins.formatting.stylua,
    require('null-ls').builtins.formatting.rustfmt,
    require('null-ls').builtins.formatting.prettierd,
    require('null-ls').builtins.diagnostics.eslint_d,
  },
})
