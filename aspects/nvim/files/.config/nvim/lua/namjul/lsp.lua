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

  vim.lsp.config('*', {
    root_markers = { '.git' },
    capabilities = capabilities,
  })

  local has_mason, mason = pcall(require, 'mason')
  if has_mason then mason.setup({
    automatic_installation = true,
    automatic_enable = false,
  }) end

  local has_mason_tool_installer, mason_tool_installer = pcall(require, 'mason-tool-installer')
  if has_mason_tool_installer then
    mason_tool_installer.setup({
      ensure_installed = {
        'rust_analyzer',
        'denols',
        'html',
        'lua_ls',
        'pyright',
        'vtsls',
        'superhtml',
        'zls',
        'pkl-lsp', -- started by pkl-neovim, not lspconfig
        'vue_ls', -- binary for the vtsls Vue plugin; not enabled as its own server
      },
    })
  end

  vim.lsp.enable({
    'denols',
    'lua_ls',
    'vtsls',
    'pyright',
  })

  vim.diagnostic.config({
    virtual_lines = true,
    -- virtual_text = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = 'rounded',
      source = true,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
        [vim.diagnostic.severity.WARN] = 'WarningMsg',
      },
    },
  })
end

return lsp
