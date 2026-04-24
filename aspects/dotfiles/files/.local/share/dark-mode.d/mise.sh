#!/usr/bin/env bash

sed --in-place --follow-symlinks 's/^color_theme *= *.*/color_theme = "default"/' ~/.config/mise/config.toml

