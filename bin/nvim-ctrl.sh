#!/usr/bin/env bash

# send command to all nvim instances
# run `nvim-ctrl.sh ':set background=dark<CR>'`

ls $XDG_RUNTIME_DIR/nvim.*.0 | xargs -I {} nvim --server {} --remote-send "$1"

