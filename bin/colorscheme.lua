#!/usr/bin/env lua

local M = {}

-- parts from https://linuxconfig.org/how-to-obtain-sunrise-sunset-time-for-any-location-from-linux-command-line
-- TODO use https://fostips.com/light-dark-command-ubuntu-22-04/

local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end


function M.set(theme, alacritty_colorscheme)
  alacritty_colorscheme = alacritty_colorscheme or "gruvbox"
  if theme == 'dark' or theme == 'light' then
    os.execute("nvim-ctrl.sh 'set background=" .. theme .. "'")
    os.execute('gsettings set org.gnome.desktop.interface color-scheme prefer-' .. theme)
    os.execute("echo 'set background=" .. theme .. "' >~/.vimrc_background")
    os.execute('alacritty msg config "$(cat ~/.config/alacritty/themes/' .. alacritty_colorscheme .. '_' .. theme .. '.toml)"')
  else
    error('theme does not exist.')
  end
end

local function parse_time(time_str)
  local hour, min, sec, period = time_str:match('(%d+):(%d+):(%d+) (%a%a)')

  if hour and min and sec and period then
    if period == 'PM' then
      hour = hour + 12
    end

    local time = os.time({
      year = os.date('%Y'),
      month = os.date('%m'),
      day = os.date('%d'),
      hour = hour,
      min = min,
      sec = sec,
    })

    return os.date(nil, time)
  else
    error('Cannot parse time_str.')
  end
end

-- requires: wget, jq
function M.sun()
  -- setup Vienna coordinates
  -- from https://www.latlong.net/
  local latitude = '48.208176'
  local longtitue = '16.373819'
  local timezoneid = 'Europe/Vienna'

  local location = latitude .. '-' .. longtitue
  local dayOfYear = os.date('%j')

  local tmpfile = '/var/tmp/' .. location .. '.' .. dayOfYear .. '.out'

  if not file_exists(tmpfile) then
    local fetchCmd = 'wget --timeout=1 -q -O - "http://api.sunrise-sunset.org/json?lat='
      .. latitude
      .. '&lng='
      .. longtitue
      .. '&tzid='
      .. timezoneid
      .. '&date=today"'
      .. ' | jq -r \'.results | {sunrise, sunset} | join("\\n")\''
    local handle = assert(io.popen(fetchCmd))
    local result = handle:read('*a')
    handle:close()

    if result ~= '' then
      os.execute('echo "' .. result .. '" > ' .. tmpfile)
    else
      print("Could not fetch sunrise-sunset data")
      return nil
    end
  end

  local file = assert(io.open(tmpfile, 'r'))

  local sunr = parse_time(file:read())
  local suns = parse_time(file:read())
  local now = os.date()
  local value = ''

  if now < sunr or now > suns then
    value = 'dark'
  elseif now > sunr then
    value = 'light'
  end
  M.set(value)
  return value
end

if arg and arg[0] then
  if arg[1] then
    M.set(arg[1])
  else
    M.sun()
  end
end

return M
