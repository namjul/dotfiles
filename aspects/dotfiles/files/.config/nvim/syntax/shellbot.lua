vim.cmd('runtime! syntax/markdown.vim')

vim.cmd([[
  set cpo&vim
  syntax match ChatGPTHeader /^ 🤓 .*/ containedin=ALL
  syntax match ChatGPTHeader /^ 🤖 .*/ containedin=ALL
  highlight def link ChatGPTHeader TermCursor
]])
