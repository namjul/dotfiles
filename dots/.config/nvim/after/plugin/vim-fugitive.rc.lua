local util = require('namjul.utils')
local opt = util.opt
local map = util.map

opt.g({ diffopt = opt.g('diffopt') .. ',vertical' })
map.g('n', '<leader>gs', ':Git<CR>')
map.g('n', '<leader>gc', ':Git commit -v<CR>')
map.g('n', '<leader>ga', ':Git add -p<CR>')
map.g('n', '<leader>gm', ':Git commit --amend<CR>')
map.g('n', '<leader>gp', ':Git push<CR>')
map.g('n', '<leader>gd', ':Gdiff<CR>')
map.g('n', '<leader>gw', ':Gwrite<CR>')
map.g('n', '<leader>gbr', ':GBrowse<CR>')
