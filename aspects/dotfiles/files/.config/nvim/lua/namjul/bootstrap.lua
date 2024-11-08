local function clone_paq()
  local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
  if vim.fn.empty(vim.fn.glob(path)) > 0 then
    vim.fn.system({
      'git',
      'clone',
      '--depth=1',
      'https://github.com/savq/paq-nvim.git',
      path,
    })
    return true
  end
  return false
end

-- from https://github.com/wincent/wincent/blob/e6fcae494c9fda25b2aa9c76941585d4eb3a97e3/aspects/nvim/files/.config/nvim/lua/wincent/plugin/load.lua
local load = function(plugin)
  if vim.v.vim_did_enter == 1 then
    -- Modifies 'runtimepath' _and_ sources files.
    vim.cmd('packadd ' .. plugin)
  else
    -- Just modifies 'runtimepath'; Vim will source the files later as part of
    -- |load-plugins| process.
    vim.cmd('packadd! ' .. plugin)
  end
end

local function bootstrap_paq(pkgs)
  local is_bootstrap = clone_paq()

  load('paq-nvim')

  local paq = require('paq')

  paq(pkgs)

  if is_bootstrap then
    -- Exit nvim after installing plugins
    vim.cmd('autocmd User PaqDoneInstall quit')
    print('==================================')
    print('    Plugins are being installed')
    print('    Wait until Packer completes,')
    print('       and restarts nvim')
    print('==================================')
    paq.install()
  end


  return is_bootstrap
end

return { bootstrap_paq = bootstrap_paq, load = load }
