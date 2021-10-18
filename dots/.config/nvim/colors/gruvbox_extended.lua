package.loaded['gruvbox'] = nil
package.loaded['gruvbox.base'] = nil
package.loaded['gruvbox.plugins.highlights'] = nil
package.loaded['gruvbox.languages'] = nil

local lush = require('lush')
local base = require('gruvbox.base')
local gruvbox = require('gruvbox')

vim.g.colors_name = 'gruvbox_extended'

local spec = lush(function()
  -- stylua: ignore
  return {
  ---@diagnostic disable-next-line: undefined-global
    VertSplitBlur { fg = base.VertSplit.bg.hex, bg = base.ColorColumn.bg.hex }
  }
end)

local gruvbox_extended = lush.merge({ gruvbox, spec })

lush(gruvbox_extended)
