local util = require('namjul.utils')

local has_dendron = pcall(require, 'dendron')

if not has_dendron then
  return
end

if not util.isVsCode() then
  require('dendron').setup({
    dendron_dir = '~/Dropbox/dendron'
    -- virtual_titles = true,
    -- mappings = true,
    -- run = nil, -- function to run when in neuron dir
    -- neuron_dir = '~/neuron', -- the directory of all of your notes, expanded by default (currently supports only one directory for notes, find a way to detect neuron.dhall to use any directory)
    -- leader = 'gz', -- the leader key to for all mappings, remember with 'go zettel'
  })
end
