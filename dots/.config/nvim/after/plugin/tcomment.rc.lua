local util = require('namjul.utils')

util.var.g({
  -- Prevent tcomment from making a zillion mappings (we just want the operator).
  tcomment_mapleader1 = '',
  tcomment_mapleader2 = '',
  tcomment_mapleader_comment_anyway = '',

  tcomment_mapleader_uncomment_anyway = 'gu', -- The default (g<) is a bit awkward to type.
  ['tcomment#filetype#guess_typescriptreact'] = 1, -- make embedded jsx work
})
