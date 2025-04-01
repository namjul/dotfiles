-- Provides a lazy autoload mechanism similar to Vimscript's autoload mechanism.
-- see https://github.com/wincent/wincent/blob/5d14c64783a4632afcd39d40cd54566a6330a3f8/aspects/nvim/files/.config/nvim/lua/wincent/autoload.lua

local autoload = function(base)
  local storage = {}
  local mt = {
    __index = function(_, key)
      if storage[key] == nil then
        storage[key] = require(base .. '.' .. key)
      end
      return storage[key]
    end,
  }

  return setmetatable({}, mt)
end

return autoload
