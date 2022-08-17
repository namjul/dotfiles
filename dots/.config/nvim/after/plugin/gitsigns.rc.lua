local has_gitsigns = pcall(require, 'gitsigns')

if not has_gitsigns then
  return
end

local util = require('namjul.utils')
local map = util.map

require('gitsigns').setup({
  current_line_blame = true,
  preview_config = {
    border = 'none',
  },
  on_attach = function(bufnr)
    -- Navigation
    map.b('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true }, bufnr)
    map.b('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true }, bufnr)

    -- Actions
    map.b('n', '<leader>hs', ':Gitsigns stage_hunk<CR>', {}, bufnr)
    map.b('v', '<leader>hs', ':Gitsigns stage_hunk<CR>', {}, bufnr)
    map.b('n', '<leader>hr', ':Gitsigns reset_hunk<CR>', {}, bufnr)
    map.b('v', '<leader>hr', ':Gitsigns reset_hunk<CR>', {}, bufnr)
    map.b('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>', {}, bufnr)
    map.b('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>', {}, bufnr)
    map.b('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>', {}, bufnr)
    map.b('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>', {}, bufnr)
    map.b('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>', {}, bufnr)
    map.b('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>', {}, bufnr)
    map.b('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>', {}, bufnr)
    map.b('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>', {}, bufnr)
    map.b('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>', {}, bufnr)

    -- Text object
    map.b('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>', {}, bufnr)
    map.b('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>', {}, bufnr)
  end,
})
