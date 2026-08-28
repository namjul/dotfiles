#!/usr/bin/env bash
# Toggle the dedicated Wayland scratch terminal (app_id scratch.term).
set -euo pipefail

export SWAYSOCK="${SWAYSOCK:-}"
if [[ -z "${SWAYSOCK}" || ! -S "${SWAYSOCK}" ]]; then
  sock=$(find /run/user/"${UID}" -maxdepth 1 -name 'sway-ipc.*.sock' -print -quit)
  [[ -n "${sock}" ]] && export SWAYSOCK="${sock}"
fi

scratch_json() {
  swaymsg -t get_tree | jq '[.. | objects | select(.app_id == "scratch.term")]'
}

count=$(scratch_json | jq 'length')
if [[ "${count}" -eq 0 ]]; then
  alacritty --class=scratch.term >/dev/null 2>&1 &
  for _ in $(seq 1 40); do
    count=$(scratch_json | jq 'length')
    [[ "${count}" -gt 0 ]] && break
    sleep 0.05
  done
fi

visible=$(scratch_json | jq '[.[] | select(.visible == true)] | length')
if [[ "${visible}" -gt 0 ]]; then
  swaymsg '[app_id="scratch.term"] scratchpad show'
  exit 0
fi

focused_output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | .name')
read -r x y w h <<<"$(swaymsg -t get_outputs | jq -r ".[] | select(.name==\"${focused_output}\") | \"\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)\"")"
width=$(awk -v w="${w}" 'BEGIN { printf "%.0f", w * 0.69 }')
height=$(awk -v h="${h}" 'BEGIN { printf "%.0f", h * 0.96 }')
pos_x=$(awk -v w="${w}" -v x="${x}" 'BEGIN { printf "%.0f", w * 0.3 + x }')
pos_y=$(awk -v h="${h}" -v y="${y}" 'BEGIN { printf "%.0f", h * 0.023 + y }')

swaymsg '[app_id="scratch.term"] scratchpad show, resize set '"${width} ${height}"', move position '"${pos_x} ${pos_y}"
