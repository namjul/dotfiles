local util = require('namjul.utils')
local map = util.map

map.g('n', 's', '<plug>(SubversiveSubstitute)', { noremap = false })
map.g('n', 'ss', '<plug>(SubversiveSubstituteLine)', { noremap = false })
map.g('n', 'S', '<plug>(SubversiveSubstituteToEndOfLine)', { noremap = false })
