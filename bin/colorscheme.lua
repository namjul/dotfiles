#!/usr/bin/env lua

local home = os.getenv("HOME")
local colorscheme = dofile(home .. "/.config/wezterm/colorscheme.lua")

if arg and arg[0] then
  if arg[1] then
    colorscheme.set(arg[1])
  else
    colorscheme.sun()
  end
end
