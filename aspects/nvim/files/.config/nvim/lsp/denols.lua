---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local project_root = vim.fs.root(bufnr, { 'deno.json' })
    if project_root then on_dir(project_root) end
  end,
}
