local util = require('namjul.utils')
local map = util.map

map.g('n', 'x', 'd')
map.g('x', 'x', 'd')
map.g('n', 'xx', 'dd')
map.g('n', 'X', 'D')
