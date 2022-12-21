local has_autopairs = pcall(require, 'nvim-autopairs')

if not has_autopairs then
  return
end


require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})
