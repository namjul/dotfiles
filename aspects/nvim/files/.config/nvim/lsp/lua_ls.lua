---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local markers = { '.luarc.json', '.luarc.jsonc', '.emmyrc.json', '.stylua.toml', 'stylua.toml', '.git' }
    local project_root = vim.fs.root(bufnr, markers)
    local config_root = vim.fn.stdpath('config')
    local name = vim.api.nvim_buf_get_name(bufnr)

    if project_root and project_root ~= vim.env.HOME then
      on_dir(project_root)
      return
    end

    if name:find(config_root, 1, true) == 1 or name:find('/.dotfiles/', 1, true) then
      on_dir(config_root)
    end
  end,
  settings = {
    Lua = {
      diagnostics = {
        enable = true,
        globals = { 'vim' },
      },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}
