local nvim_lsp = require('lspconfig')
local vimp = require('vimp')
local util = require('namjul.utils')

local on_attach = function(client, bufnr)
  -- Mappings.
  local opts = { 'silent', 'override' }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vimp.add_buffer_maps(bufnr, function()
    vimp.nnoremap(opts, '[d', function()
      vim.lsp.diagnostic.goto_prev({ enable_popup = false })
    end)
    vimp.nnoremap(opts, ']d', function()
      vim.lsp.diagnostic.goto_next({ enable_popup = false })
    end)
    vimp.nnoremap(opts, 'gd', function()
      vim.lsp.buf.definition()
    end)
    vimp.nnoremap(opts, 'K', function()
      if ({ vim = true, lua = true, help = true })[vim.bo.filetype] then
        vim.fn.execute('h ' .. vim.fn.expand('<cword>'))
      end
      vim.lsp.buf.hover()
    end)
    vimp.nnoremap(opts, '<leader>rn', function()
      vim.lsp.buf.rename()
    end)
    vimp.nnoremap(opts, 'gr', function()
      vim.lsp.buf.references()
    end)
    vimp.nnoremap(util.shallow_merge(opts, { 'repeatable' }), 'gp', function()
      vim.lsp.diagnostic.show_line_diagnostics({ show_header = false })
    end)
    vimp.nnoremap(opts, '<leader>d', function()
      vim.lsp.diagnostic.set_loclist()
    end)
    vimp.nnoremap(opts, 'ff', function()
      vim.lsp.buf.formatting()
    end)
  end)

  -- formatting
  if client.resolved_capabilities.document_formatting then
    vim.cmd([[
      augroup NamjulFormat
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync(nil, nil, { 'efm' })
      augroup END
    ]])
  end
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

nvim_lsp.tsserver.setup({
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
  flags = {
    debounce_text_changes = 150,
  },
})

-- setup diagnostics with errorformat (efm)
-- for available options see https://github.com/mattn/efm-langserver/blob/master/langserver/handler.go#L53
local eslint = {
  prefix = 'eslint',
  lintCommand = 'eslint_d -f visualstudio --stdin --stdin-filename ${INPUT}',
  lintFormats = { '%f(%l,%c): %tarning %m', '%f(%l,%c): %rror %m' }, -- see https://eslint.org/docs/user-guide/formatters/#visualstudio formatter, https://github.com/reviewdog/errorformat
  lintIgnoreExitCode = true,
  lintStdin = true,
}

local stylua = {
  prefix = 'stylua',
  formatCommand = 'stylua --search-parent-directories --stdin-filepath=${INPUT} -',
  formatStdin = true,
}

local prettier = {
  formatCommand = 'prettier --stdin-filepath=${INPUT}',
  formatStdin = true,
}

nvim_lsp.efm.setup({
  -- cmd = { 'efm-langserver', '-logfile', '/tmp/efm.log', '-loglevel', '5' },
  init_options = { documentFormatting = true },
  on_attach = on_attach,
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'lua',
    'markdown',
    'json',
    'jsonc',
    'css',
  },
  flags = {
    debounce_text_changes = 150,
  },
  root_dir = function(fname)
    return nvim_lsp.util.root_pattern('.eslintrc.js', '.git')(fname)
  end,
  settings = {
    rootMarkers = { '.eslintrc.js', '.git/' },
    languages = {
      typescript = { prettier, eslint },
      javascript = { prettier, eslint },
      typescriptreact = { prettier, eslint },
      javascriptreact = { prettier, eslint },
      ['javascript.jsx'] = { prettier, eslint },
      ['typescript.tsx'] = { prettier, eslint },
      lua = { stylua },
      markdown = { prettier },
      json = { prettier },
      jsonc = { prettier },
      css = { prettier },
    },
  },
})

local cmd = nil

if vim.fn.has('unix') == 1 then
  cmd = vim.fn.expand('~/code/lua-language-server/bin/Linux/lua-language-server')
  if vim.fn.executable(cmd) == 1 then
    cmd = { cmd, '-E', vim.fn.expand('~/code/lua-language-server/main.lua') }
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

print(cmd)

if cmd ~= nil then
  require('lspconfig').sumneko_lua.setup({
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