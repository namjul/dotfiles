#!/usr/bin/env bash
set -euo pipefail

PING_CMD="${NETWORK_PING:-ping}"
IWCTL_CMD="${NETWORK_IWCTL:-iwctl}"
GUM_CMD="${NETWORK_GUM:-gum}"
SLEEP_CMD="${NETWORK_SLEEP:-sleep}"
WAIT_TRIES="${NETWORK_WAIT_TRIES:-8}"
WAIT_SLEEP="${NETWORK_WAIT_SLEEP:-2}"

abort() {
  printf '%s\n' "$1" >&2
  exit 1
}

have_link() {
  # -W3 so a missing default route does not hang the gate.
  "$PING_CMD" -c1 -W3 archlinux.org >/dev/null 2>&1
}

have_cmd() {
  local cmd="$1"
  if [[ "$cmd" == */* ]]; then
    [[ -x "$cmd" ]]
  else
    command -v "$cmd" >/dev/null 2>&1
  fi
}

wait_for_link() {
  local n=0
  printf '%s\n' "Waiting for Ethernet..." >&2
  while ((n < WAIT_TRIES)); do
    n=$((n + 1))
    if have_link; then
      return 0
    fi
    "$SLEEP_CMD" "$WAIT_SLEEP"
  done
  return 1
}

strip_ansi() {
  sed 's/\x1b\[[0-9;]*m//g'
}

list_stations() {
  local line name mode
  while IFS= read -r line; do
    line=$(printf '%s\n' "$line" | strip_ansi)
    [[ "$line" == *station* ]] || continue
    name=$(awk '{print $1}' <<<"$line")
    mode=$(awk '{print $NF}' <<<"$line")
    [[ "$mode" == station && -n "$name" && "$name" != Name ]] || continue
    printf '%s\n' "$name"
  done < <("$IWCTL_CMD" device list)
}

pick_device() {
  local devices="$1"
  if [[ $(printf '%s\n' "$devices" | wc -l) -eq 1 ]]; then
    printf '%s\n' "$devices"
    return
  fi
  printf '%s\n' "$devices" | "$GUM_CMD" choose --header "Wi-Fi device"
}

# iwctl paints SSID tables; strip so gum and the parser see the name, not escapes.
network_rows() {
  local device="$1" line name security
  while IFS= read -r line; do
    line=$(printf '%s\n' "$line" | strip_ansi)
    [[ -n "$line" ]] || continue
    [[ "$line" == *"Security"* ]] && continue
    [[ "$line" == *"--"* ]] && continue
    security=$(awk '{print $(NF-1)}' <<<"$line")
    case "$security" in
      psk | open | wep | 8021x) ;;
      *) continue ;;
    esac
    name=$(awk '{ $NF=""; $(NF-1)=""; sub(/[ \t]+$/, ""); print }' <<<"$line")
    name=${name#> }
    name=${name#>}
    name=${name#"${name%%[![:space:]]*}"}
    [[ -n "$name" ]] || continue
    printf '%s\t%s\n' "$name" "$security"
  done < <("$IWCTL_CMD" station "$device" get-networks)
}

printf '%s\n' "Checking network..." >&2
if have_link; then
  exit 0
fi

stations=""
if have_cmd "$IWCTL_CMD"; then
  stations=$(list_stations)
fi

if [[ -z "$stations" ]]; then
  if wait_for_link; then
    exit 0
  fi
  abort "No network and no Wi-Fi radio. Wait for Ethernet DHCP, then re-run."
fi

if ! have_cmd "$GUM_CMD"; then
  cat >&2 <<'EOF'
No network, and gum is not installed. On the official ISO, connect first:

  iwctl
  # device list
  # station wlan0 scan
  # station wlan0 get-networks
  # station wlan0 connect SSID
  ping -c 1 archlinux.org

Then re-run.
EOF
  exit 1
fi

device=$(pick_device "$stations") || abort "Aborted."
"$IWCTL_CMD" station "$device" scan >/dev/null
# iwd scan results are not instant; a short wait is enough on real hardware.
"$SLEEP_CMD" 2

rows=$(network_rows "$device")
[[ -n "$rows" ]] || abort "No Wi-Fi networks."

ssid=$("$GUM_CMD" choose --header "Wi-Fi network" <<<"$(printf '%s\n' "$rows" | cut -f1)") || abort "Aborted."
security=$(printf '%s\n' "$rows" | awk -F'\t' -v s="$ssid" '$1==s{print $2; exit}')

if [[ "$security" == open ]]; then
  "$IWCTL_CMD" station "$device" connect "$ssid"
else
  pass=$("$GUM_CMD" input --password --prompt "Password> ") || abort "Aborted."
  [[ -n "$pass" ]] || abort "Empty password."
  # iwd has no non-interactive password prompt; the PSK has to go on argv.
  "$IWCTL_CMD" --passphrase="$pass" station "$device" connect "$ssid"
fi

have_link || abort "Still no network after connect."
