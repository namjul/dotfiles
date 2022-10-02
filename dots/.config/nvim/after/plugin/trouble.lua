local has_trouble = pcall(require, 'trouble')

if not has_trouble then
  return
end

require('trouble').setup({
  icons = false,
})


local has_pinnacle = pcall(require, 'wincent.pinnacle')

if not has_pinnacle then
  return
end

local pinnacle = require('wincent.pinnacle')
