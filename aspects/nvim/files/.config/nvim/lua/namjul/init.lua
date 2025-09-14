local autoload = require('namjul.autoload')

local namjul = autoload('namjul')

-- Using a real global here to make sure anything stashed in here (and
-- in `namjul.g`) survives even after the last reference to it goes away.
_G.namjul = namjul

return namjul
