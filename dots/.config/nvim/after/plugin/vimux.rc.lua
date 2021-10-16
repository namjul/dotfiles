local util = require('namjul.utils')
local map = util.map

map.g('n', '<leader>vp', ':VimuxPromptCommand<CR>') -- Prompt for a command to run
map.g('n', '<leader>vl', ':VimuxRunLastCommand<CR>') -- Run last command executed by VimuxRunCommand
map.g('n', '<leader>vi', ':VimuxInspectRunner<CR>') -- Inspect runner pane
map.g('n', '<leader>vz', ':VimuxZoomRunner<CR>') -- Zoom the tmux runner pane
