
local has_lint, lint = pcall(require, 'lint')

if has_lint then

  local linters = {
    eslint = {
      "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" 
    }
  }

  -- register each linter by filetype
  for linter, filetypes in pairs(linters) do
    for _, ft in ipairs(filetypes) do
      lint.linters_by_ft[ft] = { linter }
    end
  end

  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      -- Only run the linter in buffers that you can modify in order to
      -- avoid superfluous noise, notably within the handy LSP pop-ups that
      -- describe the hovered symbol using Markdown.
      if vim.bo.modifiable then

        -- check if linter is is available
        for linter in pairs(linters) do
          if vim.fn.executable(lint.linters[linter].cmd()) == 1 then
            lint.try_lint(linter)
          end
        end

      end
    end,
  })
end
