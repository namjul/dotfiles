local has_neuron = pcall(require, 'neuron')

if not has_neuron then
  return
end

-- require('neuron').setup({
--   virtual_titles = true,
--   mappings = true,
--   run = nil, -- function to run when in neuron dir
--   neuron_dir = '~/code/neuron/doc', -- the directory of all of your notes, expanded by default (currently supports only one directory for notes, find a way to detect neuron.dhall to use any directory)
--   leader = 'gz', -- the leader key to for all mappings, remember with 'go zettel'
-- })
