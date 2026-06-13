#!/usr/bin/env bash

sed --in-place --follow-symlinks 's/gruvbox-light/gruvbox-dark/' ~/.config/tmux/colors.conf
tmux source-file ~/.config/tmux/tmux.conf
