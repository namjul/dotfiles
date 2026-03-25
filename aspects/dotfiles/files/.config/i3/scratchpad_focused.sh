#!/usr/bin/env bash

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

# Get the currently focused output
focused_output=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused == true) | .output')

# Get geometry of that output
read x y w h <<< $(i3-msg -t get_outputs | jq -r ".[] | select(.name==\"$focused_output\") | \"\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)\"")

# Desired proportions (like your 80ppt x 98ppt)
width=$(printf "%.0f" "$(echo "$w * 0.69" | bc)")
height=$(printf "%.0f" "$(echo "$h * 0.96" | bc)")

# Position: 1% inset
pos_x=$(printf "%.0f" "$(echo "$w * 0.3 + $x" | bc)")
pos_y=$(printf "%.0f" "$(echo "$h * 0.023 + $y" | bc)")

# Check if scratchpad is already visible on the focused workspace
focused_workspace=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name')
scratchpad_on_workspace=$(i3-msg -t get_tree | jq -r ".. | select(.type? == \"workspace\" and .name == \"$focused_workspace\") | .. | select(.scratchpad_state? == \"changed\") | .id" | wc -l)

# Toggle scratchpad and only resize/move if we're showing it
if [ "$scratchpad_on_workspace" -eq 0 ]; then
    i3-msg "scratchpad show, resize set $width $height, move position $pos_x $pos_y"
else
    i3-msg "scratchpad show"
fi
