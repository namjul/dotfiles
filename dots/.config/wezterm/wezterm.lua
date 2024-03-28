local wezterm = require('wezterm')

-- Allow working with both the current release and the nightly
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local light = 'GruvboxLight'
local dark = 'GruvboxDark'

config.color_scheme = dark
config.font = wezterm.font('JetBrains Mono')
config.enable_tab_bar = false

config.keys = {
  -- Turn off the default ALT-Enter Fullscreen action, since i3 already does this and frees the binding.
  {
    key = 'Enter',
    mods = 'ALT',
    action = wezterm.action.DisableDefaultAssignment,
  },
}

-- listen to user vars and change configs
-- https://wezfurlong.org/wezterm/recipes/passing-data.html#user-vars
wezterm.on('user-var-changed', function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}

  -- change color_theme
  if name == 'theme' then
    if value == 'dark' then
      overrides.color_scheme = dark
    end
    if value == 'light' then
      overrides.color_scheme = light
    end
  end

  window:set_config_overrides(overrides)
end)

return config
