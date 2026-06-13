#!/usr/bin/env bash

sed --in-place --follow-symlinks 's/gruvbox-dark/gruvbox-light/' ~/.config/tmux/colors.conf
tmux source-file ~/.config/tmux/tmux.conf
