local util = require('namjul.utils')

util.var.g({
  vim_markdown_fenced_languages = {
    'jsx=javascriptreact',
    'js=javascript',
    'tsx=typescriptreact',
    'ts=typescriptreact',
    'yarn=sh',
    'git=sh',
    'yml=yaml',
  },
  vim_markdown_no_extensions_in_markdown = 1,
  vim_markdown_new_list_item_indent = 0,
  vim_markdown_frontmatter = 1,
  vim_markdown_folding_disabled = 1,
})
