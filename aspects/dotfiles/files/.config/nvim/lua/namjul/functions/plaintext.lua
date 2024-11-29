
local function plaintext()

  vim.opt_local.concealcursor = 'nc'
  vim.opt_local.list = false
  vim.opt_local.textwidth = 0
  vim.opt_local.wrap = true
  vim.opt_local.wrapmargin = 0


  vim.keymap.set('n', 'j', 'gj', { buffer = true })
  vim.keymap.set('n', 'k', 'gk', { buffer = true })

  -- Break undo sequences into chunks (after punctuation); see: `:h i_CTRL-G_u`
  -- Create undo 'snapshots' when being in inline editing.
  --
  -- From:
  -- - https://github.com/wincent/wincent/blob/44b112f26ec6435a9b78e64225eb0f9082999c1e/aspects/vim/files/.vim/autoload/wincent/functions.vim#L32
  -- - https://twitter.com/vimgifs/status/913390282242232320
  --

  vim.keymap.set('i', '!', '!<C-g>u', { buffer = true })
  vim.keymap.set('i', ',', ',<C-g>u', { buffer = true })
  vim.keymap.set('i', '.', '.<C-g>u', { buffer = true })
  vim.keymap.set('i', ':', ':<C-g>u', { buffer = true })
  vim.keymap.set('i', ';', ';<C-g>u', { buffer = true })
  vim.keymap.set('i', '?', '?<C-g>u', { buffer = true })

end

return plaintext
