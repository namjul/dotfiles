#!/usr/bin/env bash

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

# Get the currently focused output
focused_output=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused == true) | .output')

# Get geometry of that output
read x y w h <<< $(i3-msg -t get_outputs | jq -r ".[] | select(.name==\"$focused_output\") | \"\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)\"")

# Desired proportions (like your 80ppt x 98ppt)
width=$(printf "%.0f" "$(echo "$w * 0.80" | bc)")
height=$(printf "%.0f" "$(echo "$h * 0.98" | bc)")

# Position: 1% inset
pos_x=$(printf "%.0f" "$(echo "$w * 0.01 + $x" | bc)")
pos_y=$(printf "%.0f" "$(echo "$h * 0.01 + $y" | bc)")

# Apply floating + resize + move commands
i3-msg "scratchpad show, [floating] resize set $width $height, move position $pos_x $pos_y"
