---@type overseer.ComponentFileDefinition
return {
  desc = 'Jump to the first quickfix item and scroll it to the top of the window',
  constructor = function()
    return {
      on_complete = function()
        vim.schedule(function()
          if vim.fn.getqflist({ size = true }).size == 0 then return end
          vim.cmd('silent! cfirst')
          vim.cmd('normal! zt')
        end)
      end,
    }
  end,
}
