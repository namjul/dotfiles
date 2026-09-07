local lsp = {}

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached', data = { bufnr = bufnr } })
  end,
})

lsp.init = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- -- Add file rename support
  -- capabilities.workspace = capabilities.workspace or {}
  -- capabilities.workspace.fileOperations = capabilities.workspace.fileOperations or {}
  -- capabilities.workspace.fileOperations.didRename = true
  -- capabilities.workspace.fileOperations.didCreate = true
  -- capabilities.workspace.fileOperations.didDelete = true

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

  vim.lsp.config('*', { capabilities = capabilities })

  local ensure_installed = {
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
  }

  local has_mason, mason = pcall(require, 'mason')
  if has_mason then mason.setup() end

  local has_mason_tool_installer, mason_tool_installer = pcall(require, 'mason-tool-installer')
  if has_mason_tool_installer then mason_tool_installer.setup({ ensure_installed = ensure_installed }) end

  local has_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if has_mason and has_mason_lspconfig then
    mason_lspconfig.setup({
      ensure_installed = {}, -- explicitly set to an empty table (populated installs via mason-tool-installer)
      automatic_enable = {
        exclude = { 'vue_ls' }, -- Vue is handled via the vtsls typescript plugin
      },
    })
  end
end

local function virtual_text_document(params)
  local bufnr = params.buf
  local actual_path = params.match:sub(1)

  local clients = vim.lsp.get_clients({ name = 'denols' })
  if #clients == 0 then return end

  local client = clients[1]
  local method = 'deno/virtualTextDocument'
  local req_params = { textDocument = { uri = actual_path } }
  local response = client.request_sync(method, req_params, 2000, 0)
  if not response or type(response.result) ~= 'string' then return end

  local lines = vim.split(response.result, '\n')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_set_option_value('readonly', true, { buf = bufnr })
  vim.api.nvim_set_option_value('modified', false, { buf = bufnr })
  vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  vim.api.nvim_buf_set_name(bufnr, actual_path)
  vim.lsp.buf_attach_client(bufnr, client.id)

  local filetype = 'typescript'
  if actual_path:sub(-3) == '.md' then filetype = 'markdown' end
  vim.api.nvim_set_option_value('filetype', filetype, { buf = bufnr })
end

vim.api.nvim_create_autocmd({ 'BufReadCmd' }, {
  pattern = { 'deno:/*' },
  callback = virtual_text_document,
})

return lsp
