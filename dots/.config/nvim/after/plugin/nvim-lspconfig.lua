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
      vim.lsp.buf.formatting()
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
    debounce_text_changes = 150,
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

---setup diagnostics with errorformat (efm) ---
-- for available options see https://github.com/mattn/efm-langserver/blob/master/langserver/handler.go#L53
-- https://github.com/creativenull/efmls-configs-nvim/blob/main/supported-linters-and-formatters.md

local efmls = require('efmls-configs')
efmls.init({
  root_dir = function(fname)
    return lspconfig.util.root_pattern('.git', 'dendron.yml')(fname)
  end,
  on_attach = on_attach,
  init_options = {
    documentFormatting = true,
  },
})

local eslint = require('efmls-configs.linters.eslint_d')
local fs = require('efmls-configs.fs')
local bin = fs.executable('eslint_d', fs.Scope.NODE)
local args = '--no-color --format visualstudio --stdin --stdin-filename ${INPUT}'
eslint = vim.tbl_extend('force', eslint, {
  lintCommand = string.format('%s %s', bin, args),
  lintFormats = { '%f(%l,%c): %tarning %m', '%f(%l,%c): %rror %m' }, -- see https://eslint.org/docs/user-guide/formatters/#visualstudio formatter, https://github.com/reviewdog/errorformat
})
local prettier = require('efmls-configs.formatters.prettier_d')
local stylua = require('efmls-configs.formatters.stylua')

efmls.setup({
  javascript = {
    linter = eslint,
    formatter = prettier,
  },
  typescript = { linter = eslint, formatter = prettier },
  typescriptreact = { linter = eslint, formatter = prettier },
  javascriptreact = { linter = eslint, formatter = prettier },
  ['javascript.jsx'] = { linter = eslint, formatter = prettier },
  ['typescript.tsx'] = { linter = eslint, formatter = prettier },
  lua = { formatter = stylua },
  markdown = { formatter = prettier },
  html = { formatter = prettier },
  handlebars = { formatter = prettier },
  json = { formatter = prettier },
  css = { formatter = prettier },
})

--[[

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
    'css',
  },
  flags = {
    debounce_text_changes = 150,
  },
  root_dir = function(fname)
    return nvim_lsp.util.root_pattern('.eslintrc.js', '.git', 'dendron.yml')(fname)
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
      css = { prettier },
    },
  },
})

--]]