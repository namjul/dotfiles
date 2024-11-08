local gsub = require('string').gsub
local gmatch = require('string').gmatch

local function slugify(string, replacement)
  if replacement == nil then
    replacement = '-'
  end
  local result = ''
  -- loop through each word or number
  for word in gmatch(string, "([%w,%.]+)") do
    result = result .. word .. replacement
  end
  -- remove trailing separator
  result = gsub(result, replacement .. "$", '')
  return result:lower()
end

return slugify
