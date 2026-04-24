#!/usr/bin/env bash

sed --in-place --follow-symlinks 's/color_theme = "gruvbox_light"/color_theme = "gruvbox_dark_2"/' ~/.config/btop/btop.conf
pkill btop && btop &

