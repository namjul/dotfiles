local util = require('namjul.utils')

local function plaintext()
  local opt = util.opt
  local map = util.map
  if vim.fn.has('conceal') == 1 then
    opt.w({ concealcursor = 'nc' })
  end

  opt.w({
    list = false,
    linebreak = true,
    wrap = true,
  })

  opt.b({
    textwidth = 0,
    wrapmargin = 0,
  })

  map.b('n', 'j', 'gj')
  map.b('n', 'k', 'gk')
  map.b('n', '0', 'g0')
  map.b('n', '^', 'g^')
  map.b('n', '$', 'g$')
  map.b('n', 'j', 'gj')
  map.b('n', 'k', 'gk')
  map.b('n', '0', 'g0')
  map.b('n', '^', 'g^')
  map.b('n', '$', 'g$')

  -- Create undo 'snapshots' when being in inline editing.
  --
  -- From:
  -- - https://github.com/wincent/wincent/blob/44b112f26ec6435a9b78e64225eb0f9082999c1e/aspects/vim/files/.vim/autoload/wincent/functions.vim#L32
  -- - https://twitter.com/vimgifs/status/913390282242232320
  --
  map.b('i', '!', '!<C-g>u')
  map.b('i', ',', ',<C-g>u')
  map.b('i', '.', '.<C-g>u')
  map.b('i', ':', ':<C-g>u')
  map.b('i', ';', ';<C-g>u')
  map.b('i', '?', '?<C-g>u')
end

return plaintext
