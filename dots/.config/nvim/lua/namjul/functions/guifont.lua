-- from https://github.com/neovide/neovide/issues/1301#issuecomment-1119370546

local M = {}

vim.g.gui_font_default_size = 10
vim.g.gui_font_size = vim.g.gui_font_default_size

function M.refreshGuiFont()
  vim.opt.guifont = string.format('%s:h%s', vim.api.nvim_get_option('guifont'), vim.g.gui_font_size)
end

function M.resizeGuiFont(delta)
  vim.g.gui_font_size = vim.g.gui_font_size + delta
  M.refreshGuiFont()
end

function M.resetGuiFont()
  vim.g.gui_font_size = vim.g.gui_font_default_size
  M.refreshGuiFont()
end

return M
