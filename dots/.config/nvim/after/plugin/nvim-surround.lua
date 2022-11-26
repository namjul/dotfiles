local has_surround = pcall(require, 'nvim-surround')

if not has_surround then
  return
end

require('nvim-surround').setup({
  keymaps = {
    -- insert = '<C-g>s',
    -- insert_line = '<C-g>S',
    -- normal = 'ys',
    -- normal_cur = 'yss',
    -- normal_line = 'yS',
    -- normal_cur_line = 'ySS',
    -- visual = 'S',
    -- visual_line = 'gS',
    -- delete = 'ds',
    -- change = 'cs',
    -- replace because of clash with `leap`
    insert = '<C-g>z',
    insert_line = 'gC-ggZ',
    normal = 'gz',
    normal_cur = 'gZ',
    normal_line = 'gzgz',
    normal_cur_line = 'gZgZ',
    visual = 'gz',
    visual_line = 'gZ',
    delete = 'gzd',
    change = 'gzc',
  },
})
