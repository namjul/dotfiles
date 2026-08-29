#!/usr/bin/env bash

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

if [[ -z ${SWAYSOCK-} || ! -S ${SWAYSOCK} ]]; then
  sock=$(find /run/user/"${UID}" -maxdepth 1 -name 'sway-ipc.*.sock' -print -quit)
  [[ -n ${sock} ]] && export SWAYSOCK="${sock}"
fi

fullscreen_file=/tmp/sway_scratchpad_fullscreen

# Shown scratch windows: "fresh" (just moved) or "changed" (shown/resized).
visible_scratches() {
  swaymsg -t get_tree | jq '[
    .. | objects
    | select((.scratchpad_state == "fresh" or .scratchpad_state == "changed") and .visible == true)
  ]'
}

visible_float_id() {
  swaymsg -t get_tree | jq -r '[
    .. | objects
    | select(.type == "floating_con")
    | select(
        (.scratchpad_state == "fresh" or .scratchpad_state == "changed")
        or any(.nodes[]; .scratchpad_state == "fresh" or .scratchpad_state == "changed")
      )
    | select(.visible == true or any(.nodes[]; .visible == true))
    | .id
  ] | first // empty'
}

place_scratch() {
  local id
  id=$(visible_float_id)
  [[ -n ${id} ]] || return 0

  # get_workspaces marks the focused workspace; the tree marks the focused pane.
  # Workspace rect is the tiling area (below the bar, inside inner gaps).
  focused_workspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name')
  read -r x y w h <<<"$(swaymsg -t get_tree | jq -r --arg n "${focused_workspace}" '
    .. | objects | select(.type == "workspace" and .name == $n)
    | "\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)"
  ')"

  # Workspace rect is already the tiling area (bar + inner gaps). Keep the
  # left inset; pin top to that base and use the same 0 inset on right/bottom.
  pos_x=$(awk -v w="${w}" -v x="${x}" 'BEGIN { printf "%.0f", w * 0.3 + x }')
  pos_y="${y}"
  width=$(awk -v w="${w}" -v x="${x}" -v px="${pos_x}" 'BEGIN { printf "%.0f", w - (px - x) }')
  height="${h}"

  swaymsg "[con_id=${id}] resize set ${width}px ${height}px, move absolute position ${pos_x} ${pos_y}"
}

scratch_fullscreen() {
  swaymsg -t get_tree | jq '
    [
      .. | objects
      | select(.type == "floating_con")
      | select(
          (.scratchpad_state == "fresh" or .scratchpad_state == "changed")
          or any(.nodes[]; .scratchpad_state == "fresh" or .scratchpad_state == "changed")
        )
      | select(.visible == true or any(.nodes[]; .visible == true))
      | .fullscreen_mode,
        (.nodes[]? | .fullscreen_mode)
    ] | max // 0
  '
}

save_fullscreen() {
  echo "${1}" >"${fullscreen_file}"
}

# Super+F: a visible fullscreen scratch is often not the focused container,
# so `fullscreen toggle` flips something else and the scratch stays full.
if [[ ${1-} == toggle-fullscreen ]]; then
  id=$(visible_float_id)
  if [[ -n ${id} ]]; then
    if [[ $(scratch_fullscreen) -ne 0 ]]; then
      swaymsg "[con_id=${id}] fullscreen disable"
      place_scratch
      save_fullscreen 0
    else
      swaymsg "[con_id=${id}] fullscreen enable"
      save_fullscreen 1
    fi
  else
    swaymsg fullscreen toggle
  fi
  exit 0
fi

last_fullscreen=0
if [[ -f ${fullscreen_file} ]]; then
  last_fullscreen=$(cat "${fullscreen_file}")
fi

after_show() {
  local id
  id=$(visible_float_id)
  [[ -n ${id} ]] || return 0
  if [[ ${last_fullscreen} -ne 0 ]]; then
    swaymsg "[con_id=${id}] fullscreen enable"
    swaymsg "[con_id=${id}] focus"
  else
    place_scratch
  fi
}

# Unscoped scratchpad show: hide the visible scratch window or cycle the stack.
# Empty scratchpad is a no-op (do not spawn).
if [[ $(visible_scratches | jq 'length') -gt 0 ]]; then
  save_fullscreen "$(scratch_fullscreen)"
fi
if ! swaymsg scratchpad show >/dev/null; then
  exit 0
fi
after_show
