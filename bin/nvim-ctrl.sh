#!/usr/bin/env bash

# send command to all nvim instances

ls $XDG_RUNTIME_DIR/nvim.*.0 | xargs -I {} nvim --server {} --remote-send "$1"

