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

local function bootstrap_paq(pkgs)
  local is_bootstrap = clone_paq()

  namjul.plugin.load('paq-nvim')

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

return bootstrap_paq
