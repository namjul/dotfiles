-- Minimal Hyprland setup
-- https://wiki.hypr.land/Configuring/Start/

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = 'rgba(33ccffee)',
      inactive_border = 'rgba(595959aa)',
    },
    layout = 'dwindle',
  },

  decoration = {
    rounding = 0,
  },

  input = {
    kb_layout = 'us',
    follow_mouse = 1,
  },
})

local terminal = 'mise r term'

local mainMod = 'SUPER' -- Sets "Windows" key as main modifier

hl.bind(mainMod .. ' + RETURN', hl.dsp.exec_cmd(terminal), { description = 'Terminal' })

hl.bind(mainMod .. ' + W', hl.dsp.window.close(), { description = 'Close window' })
hl.bind(mainMod .. ' + F', hl.dsp.window.fullscreen({ mode = 'fullscreen' }), { description = 'Fullscreen' })

hl.bind(mainMod .. ' + M', hl.dsp.exit(), { description = 'Exit Hyprland' })
hl.bind(mainMod .. ' + SHIFT + Q', hl.dsp.exit(), { description = 'Exit Hyprland' })
