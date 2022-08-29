local util = require('namjul.utils')
local map = util.map
local var = util.var

var.g({ yoinkIncludeDeleteOperations = 1 })
map.g('n', '<C-n>', '<Plug>(YoinkPostPasteSwapBack)', { noremap = false })
map.g('n', '<C-p>', '<Plug>(YoinkPostPasteSwapForward)', { noremap = false })
map.g('n', 'p', '<Plug>(YoinkPaste_p)', { noremap = false })
map.g('n', 'P', '<Plug>(YoinkPaste_P)', { noremap = false })

-- https://github.com/svermeulen/vim-yoink/issues/16#issuecomment-632234373
var.g({
  clipboard = {
    name = 'xsel_override',
    copy = {
      ['+'] = 'xsel --input --clipboard',
      ['*'] = 'xsel --input --primary',
    },
    paste = {
      ['+'] = 'xsel --output --clipboard',
      ['*'] = 'xsel --output --primary',
    },
    cache_enabled = 1,
  },
})
