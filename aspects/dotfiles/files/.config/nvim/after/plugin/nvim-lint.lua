
local has_lint, lint = pcall(require, 'lint')

if has_lint then

  lint.linters_by_ft = {
    javascript = { "eslint" },
    javascriptreact = { "eslint" },
    typescript = { "eslint" },
    typescriptreact = { "eslint" },
    vue = { "eslint" },
  }

  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      -- Only run the linter in buffers that you can modify in order to
      -- avoid superfluous noise, notably within the handy LSP pop-ups that
      -- describe the hovered symbol using Markdown.
      if vim.bo.modifiable then
        require("lint").try_lint()
      end
    end,
  })
end
