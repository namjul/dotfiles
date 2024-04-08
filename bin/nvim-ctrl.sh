#!/usr/bin/env bash

# send command to all nvim instances
# run `nvim-ctrl.sh ':set background=dark<CR>'`
# see: https://github.com/chmln/nvim-ctrl/issues/1

ls $XDG_RUNTIME_DIR/nvim.*.0 2>/dev/null | xargs -I {} nvim --server {} --remote-expr "execute('$1')"

