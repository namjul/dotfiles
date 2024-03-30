local wezterm = require('wezterm')
local mux = wezterm.mux
local set_colorscheme = require('./set_colorscheme')

local config = {}

-- Allow working with both the current release and the nightly
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local light = 'GruvboxLight'
local dark = 'GruvboxDark'

config.color_scheme = dark
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }
config.font = wezterm.font('JetBrains Mono')
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.disable_default_key_bindings = true

config.keys = {

  {
    mods = 'LEADER',
    key = 'm',
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    mods = 'LEADER',
    key = 'c',
    action = wezterm.action.SpawnTab('DefaultDomain'),
  },

  -- tab navs
  {
    mods = 'LEADER',
    key = 'p',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    mods = 'LEADER',
    key = 'n',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    mods = 'LEADER',
    key = '9',
    action = wezterm.action.ActivateTab(-1),
  },
  {
    mods = 'LEADER',
    key = '1',
    action = wezterm.action.ActivateTab(0),
  },

  -- splitting
  {
    mods = 'LEADER',
    key = '-',
    action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
  },
  {
    mods = 'LEADER',
    key = '|',
    action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
  },

  -- pane movement
  {
    mods = 'LEADER',
    key = 'h',
    action = wezterm.action.ActivatePaneDirection('Left'),
  },
  {
    mods = 'LEADER',
    key = 'l',
    action = wezterm.action.ActivatePaneDirection('Right'),
  },

  {
    mods = 'LEADER',
    key = 'j',
    action = wezterm.action.ActivatePaneDirection('Down'),
  },
  {
    mods = 'LEADER',
    key = 'k',
    action = wezterm.action.ActivatePaneDirection('Up'),
  },

  -- resize movement
  {
    mods = 'SUPER',
    key = 'h',
    action = wezterm.action.AdjustPaneSize({ 'Left', 3 }),
  },
  {
    mods = 'SUPER',
    key = 'l',
    action = wezterm.action.AdjustPaneSize({ 'Right', 3 }),
  },
  {
    mods = 'SUPER',
    key = 'j',
    action = wezterm.action.AdjustPaneSize({ 'Down', 3 }),
  },
  {
    mods = 'LEADER',
    key = 'K',
    action = wezterm.action.AdjustPaneSize({ 'Up', 3 }),
  },

  {
    mods = 'LEADER',
    key = 'Space',
    action = wezterm.action.RotatePanes('Clockwise'),
  },

  -- show the pane selection mode, but have it swap the active and selected panes
  {
    mods = 'LEADER',
    key = '0',
    action = wezterm.action.PaneSelect({
      mode = 'SwapWithActive',
    }),
  },

  -- scroll
  { key = 'k', mods = 'SHIFT', action = wezterm.action.ScrollByPage(-1) },
  { key = 'j', mods = 'SHIFT', action = wezterm.action.ScrollByPage(1) },

  -- fonts sizes
  {
    mods = 'CTRL',
    key = '0',
    action = wezterm.action.ResetFontSize,
  },
  {
    mods = 'CTRL',
    key = '+',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    mods = 'CTRL',
    key = '-',
    action = wezterm.action.DecreaseFontSize,
  },

  -- rest
  {
    mods = 'LEADER',
    key = 'P',
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    mods = 'LEADER',
    key = 'q',
    action = wezterm.action.QuickSelect,
  },

  {
    mods = 'LEADER',
    key = 'x',
    action = wezterm.action.ActivateCopyMode,
  },
  {
    mods = 'LEADER',
    key = 'f',
    action = wezterm.action.Search({ CaseSensitiveString = '' }),
  },
  {
    mods = 'LEADER',
    key = 'w',
    action = wezterm.action.CloseCurrentTab({ confirm = true }),
  },
}

wezterm.on('gui-attached', function()
  local workspace = mux.get_active_workspace()
  for _, window in ipairs(mux.all_windows()) do
    local overrides = window:gui_window():get_config_overrides() or {}
    local theme = set_colorscheme.run()

    -- change color_theme
    if theme == 'dark' then
      overrides.color_scheme = dark
    end
    if theme == 'light' then
      overrides.color_scheme = light
    end

    window:gui_window():set_config_overrides(overrides)
  end
end)

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

wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime('%Y.%m.%d %H:%M')
  local leader = ''
  if window:leader_is_active() then
    leader = 'LEADER'
  end
  window:set_right_status(wezterm.format({
    { Text = date .. ' ' },
    { Text = leader .. ' ' },
  }))
end)

return config
