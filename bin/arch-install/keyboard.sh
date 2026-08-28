#!/usr/bin/env bash
set -euo pipefail

GUM_CMD="${KEYBOARD_GUM:-gum}"
LOADKEYS_CMD="${KEYBOARD_LOADKEYS:-loadkeys}"
DEFAULT_KEYBOARD="${ARCH_INSTALL_KEYBOARD:-de}"
STAMP="${ARCH_INSTALL_KEYBOARD_STAMP:-/run/arch-install-keyboard}"

abort() {
  printf '%s\n' "$1" >&2
  exit 1
}

have_cmd() {
  local cmd="$1"
  if [[ "$cmd" == */* ]]; then
    [[ -x "$cmd" ]]
  else
    command -v "$cmd" >/dev/null 2>&1
  fi
}

list_keymaps() {
  local maps=""
  if maps=$(localectl list-keymaps 2>/dev/null) && [[ -n "$maps" ]]; then
    printf '%s\n' "$maps"
    return 0
  fi
  if [[ -d /usr/share/kbd/keymaps ]]; then
    maps=$(
      find /usr/share/kbd/keymaps -type f \( -name '*.map' -o -name '*.map.gz' -o -name '*.kmap' -o -name '*.kmap.gz' \) -printf '%f\n' |
        sed -E 's/\.(map|kmap)(\.gz)?$//' |
        sort -u
    )
    if [[ -n "$maps" ]]; then
      printf '%s\n' "$maps"
      return 0
    fi
  fi
  printf '%s\n' de us uk fr it es dvorak colemak
}

apply_keyboard() {
  local keyboard="$1"
  "$LOADKEYS_CMD" "$keyboard"
  if mkdir -p "$(dirname "$STAMP")" 2>/dev/null; then
    printf '%s\n' "$keyboard" >"$STAMP"
  fi
}

if [[ -f "$STAMP" ]]; then
  apply_keyboard "$(<"$STAMP")"
  exit 0
fi

if ! have_cmd "$GUM_CMD"; then
  cat >&2 <<'EOF'
Need a keyboard layout before Wi-Fi. gum is not installed. On the official ISO:

  loadkeys de

Then re-run.
EOF
  exit 1
fi

maps=$(list_keymaps)
keyboard=$(printf '%s\n' "$maps" | "$GUM_CMD" filter --height 12 --header "Keyboard layout" --value "$DEFAULT_KEYBOARD") || abort "Aborted."
[[ -n "$keyboard" ]] || abort "Empty keyboard layout."
apply_keyboard "$keyboard"
