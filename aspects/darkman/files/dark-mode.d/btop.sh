#!/usr/bin/env bash

sed -i 's/color_theme = "gruvbox_light"/color_theme = "gruvbox_dark_2"/' ~/.config/btop/btop.conf
pkill btop && btop &

