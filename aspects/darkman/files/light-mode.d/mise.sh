#!/usr/bin/env bash

sed --in-place --follow-symlinks 's/^color_theme *= *.*/color_theme = "base16"/' ~/.config/mise/config.toml

