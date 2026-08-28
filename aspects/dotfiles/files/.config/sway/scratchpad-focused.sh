#!/usr/bin/env bash

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

if [[ -z ${SWAYSOCK-} || ! -S ${SWAYSOCK} ]]; then
  sock=$(find /run/user/"${UID}" -maxdepth 1 -name 'sway-ipc.*.sock' -print -quit)
  [[ -n ${sock} ]] && export SWAYSOCK="${sock}"
fi

scratch_json() {
  swaymsg -t get_tree | jq '[.. | objects | select(.app_id == "scratch.term")]'
}

# Read last fullscreen state (default 0 if missing)
last_fullscreen=0
if [ -f /tmp/sway_scratchpad_fullscreen ]; then
    last_fullscreen=$(cat /tmp/sway_scratchpad_fullscreen)
fi

count=$(scratch_json | jq 'length')
if [[ "${count}" -eq 0 ]]; then
  launch-terminal --class=scratch.term >/dev/null 2>&1 &
  for _ in $(seq 1 40); do
    count=$(scratch_json | jq 'length')
    [[ "${count}" -gt 0 ]] && break
    sleep 0.05
  done
fi

# get_workspaces marks the focused workspace; the tree marks the focused pane.
# Workspace rect starts at the bar's bottom. i3 used 2.3% of the output to
# clear the bar; here that inset would leave a gap, so y is used as-is.
focused_workspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name')
read -r x y w h <<<"$(swaymsg -t get_tree | jq -r --arg n "${focused_workspace}" '
  .. | objects | select(.type == "workspace" and .name == $n)
  | "\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)"
')"

width=$(awk -v w="${w}" 'BEGIN { printf "%.0f", w * 0.69 }')
height=$(awk -v h="${h}" 'BEGIN { printf "%.0f", h * 0.96 }')
pos_x=$(awk -v w="${w}" -v x="${x}" 'BEGIN { printf "%.0f", w * 0.3 + x }')
pos_y="${y}"

visible=$(scratch_json | jq '[.[] | select(.visible == true)] | length')

floating_id() {
  swaymsg -t get_tree | jq '[.. | objects | select(.type == "floating_con") | select(any(.nodes[]; .app_id == "scratch.term")) | .id] | first'
}

if [ "${visible}" -eq 0 ]; then
   if [ "${last_fullscreen}" -ne 0 ]; then
        swaymsg '[app_id="scratch.term"] scratchpad show, fullscreen enable'
    else
        swaymsg '[app_id="scratch.term"] scratchpad show'
        swaymsg "[con_id=$(floating_id)] resize set ${width}px ${height}px, move absolute position ${pos_x} ${pos_y}"
    fi
else
  current_fullscreen=$(swaymsg -t get_tree | jq '.. | objects | select(.app_id == "scratch.term") | .fullscreen_mode' | head -1)
  echo "${current_fullscreen}" > /tmp/sway_scratchpad_fullscreen
  swaymsg '[app_id="scratch.term"] scratchpad show'
fi
