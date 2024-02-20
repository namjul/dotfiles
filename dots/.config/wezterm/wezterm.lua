local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Gruvbox Dark (Gogh)'
config.font = wezterm.font 'JetBrains Mono'
config.enable_tab_bar = false

config.keys = {
  -- Turn off the default ALT-Enter Fullscreen action, since i3 already does this and frees the binding.
  {
    key = 'Enter',
    mods = 'ALT',
    action = wezterm.action.DisableDefaultAssignment,
  },
}

return config
