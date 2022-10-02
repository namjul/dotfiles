local has_lspconfig = pcall(require, 'lspconfig')

if not has_lspconfig then
  return
end

local lspconfig = require('lspconfig')

local on_attach = function(_, bufnr)
  --- mappings ---

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local mappings = {
    ['[d'] = function()
      vim.diagnostic.goto_prev({ enable_popup = false })
    end,
    [']d'] = function()
      vim.diagnostic.goto_next({ enable_popup = false })
    end,
    ['gd'] = function()
      vim.lsp.buf.definition()
    end,
    ['K'] = function()
      if ({ vim = true, lua = true, help = true })[vim.bo.filetype] then
        vim.fn.execute('h ' .. vim.fn.expand('<cword>'))
      end
      vim.lsp.buf.hover()
    end,
    ['<leader>rn'] = function()
      vim.lsp.buf.rename()
    end,
    ['gr'] = function()
      vim.lsp.buf.references()
    end,
    -- ['gp']= function()
    --   vim.lsp.diagnostic.show_line_diagnostics({ show_header = false })
    -- end,
    -- ['<leader>d']= function()
    --   vim.lsp.diagnostic.set_loclist()
    -- end,
    ['ff'] = function()
      vim.lsp.buf.format({ async = true })
    end,
  }

  for k, v in pairs(mappings) do
    vim.keymap.set('n', k, v, { buffer = bufnr, silent = true })
  end

  -- formatting
  -- if client.resolved_capabilities.document_formatting then
  --   vim.cmd([[
  --     augroup NamjulFormat
  --     autocmd! * <buffer>
  --     autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync(nil, nil, { 'efm' })
  --     augroup END
  --   ]])
  -- end
end

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
  on_attach = on_attach,
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
    on_attach = on_attach,
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
  on_attach = on_attach,
  -- Server-specific settings...
  settings = {
    ['rust-analyzer'] = {},
  },
})

--- formating and diagnostics ---

require('null-ls').setup({
  on_attach = on_attach,
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
