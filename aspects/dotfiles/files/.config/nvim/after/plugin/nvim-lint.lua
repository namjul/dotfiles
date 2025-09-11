local has_lint, lint = pcall(require, 'lint')

local function find_nodemodules_bin(binary_name)
  local current_dir = vim.fn.getcwd()

  local matcher = function(dir)
    local binary_path = dir .. "/node_modules/.bin/" .. binary_name
    if vim.fn.filereadable(binary_path) == 1 then
      return binary_path
    end
    return nil
  end

  local start_match = matcher(current_dir)
  if start_match then
    return start_match
  end

  for path in vim.fs.parents(current_dir) do
    local match = matcher(path)
    if match then
      return match
    end
  end

  return nil -- Not found
end

local get_lsp_client = function()
  -- Get lsp client for current buffer
  local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if next(clients) == nil then
    return nil
  end

  for _, client in pairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      return client
    end
  end

  return nil
end

if has_lint then

  local linters = {
    eslint = {
      "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue"
    }
  }

  local eslint = require('lint').linters.eslint
  eslint.cmd = function ()
    local binary_name = 'eslint'
    local local_binary = find_nodemodules_bin(binary_name)
    return local_binary or binary_name
  end

  -- register each linter by filetype
  for linter, filetypes in pairs(linters) do
    for _, ft in ipairs(filetypes) do
      lint.linters_by_ft[ft] = { linter }
    end
  end

  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }, {
    group = lint_augroup,
    callback = function()
      -- Only run the linter in buffers that you can modify in order to
      -- avoid superfluous noise, notably within the handy LSP pop-ups that
      -- describe the hovered symbol using Markdown.
      if vim.bo.modifiable then
        local client = get_lsp_client() or {}
        -- check if linter is is available
        for linter in pairs(linters) do
          if vim.fn.executable(lint.linters[linter].cmd()) == 1 then
            lint.try_lint(linter, { cwd = client.root_dir }) -- `try_lint` includes a filetypecheck which `lint.try_lint(linter)` does not
          end
        end
      end
    end,
  })
end
