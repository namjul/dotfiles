#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NETWORK="$DIR/network.sh"
failed=0

assert_exit() {
  local expected="$1" name="$2"
  shift 2
  set +e
  local output
  output="$("$@" 2>&1)"
  local actual=$?
  set -e
  if [[ $actual -ne $expected ]]; then
    echo "FAIL $name: exit $actual (want $expected)"
    printf '%s\n' "$output"
    failed=1
  else
    echo "ok   $name"
  fi
}

assert_contains() {
  local name="$1" needle="$2"
  shift 2
  set +e
  local output
  output="$("$@" 2>&1)"
  local actual=$?
  set -e
  if [[ $actual -eq 0 ]]; then
    echo "FAIL $name: expected failure, got 0"
    printf '%s\n' "$output"
    failed=1
    return
  fi
  if [[ "$output" != *"$needle"* ]]; then
    echo "FAIL $name: output missing '$needle'"
    printf '%s\n' "$output"
    failed=1
    return
  fi
  echo "ok   $name"
}

make_ping() {
  local dest="$1" mode="$2"
  cat >"$dest" <<EOF
#!/usr/bin/env bash
count_file="${dest}.count"
n=0
[[ -f "\$count_file" ]] && n=\$(cat "\$count_file")
n=\$((n + 1))
echo "\$n" >"\$count_file"
case "$mode" in
  always-ok) exit 0 ;;
  always-fail) exit 1 ;;
  fail-then-ok)
    if [[ \$n -eq 1 ]]; then exit 1; fi
    exit 0
    ;;
esac
EOF
  chmod +x "$dest"
}

make_iwctl() {
  local dest="$1" mode="$2"
  cat >"$dest" <<EOF
#!/usr/bin/env bash
log="${dest}.log"
printf '%s\n' "\$*" >>"\$log"
case "$mode" in
  no-radio)
    if [[ "\$1" == device && "\$2" == list ]]; then
      echo "  Name        Address  Powered  Adapter  Mode"
      exit 0
    fi
    exit 1
    ;;
  one-station)
    if [[ "\$1" == device && "\$2" == list ]]; then
      echo "  wlan0  00:00:00:00:00:00  on  phy0  station"
      exit 0
    fi
    if [[ "\$1" == station && "\$3" == scan ]]; then
      exit 0
    fi
    if [[ "\$1" == station && "\$3" == get-networks ]]; then
      echo "Network name  Security  Signal"
      echo "HomeNet       psk       ****"
      echo "Cafe          open      ***"
      exit 0
    fi
    if [[ "\$1" == --passphrase=* && "\$2" == station && "\$4" == connect ]]; then
      exit 0
    fi
    if [[ "\$1" == station && "\$3" == connect ]]; then
      exit 0
    fi
    exit 1
    ;;
esac
EOF
  chmod +x "$dest"
}

make_gum() {
  local dest="$1" choice="$2" password="${3:-}"
  cat >"$dest" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == choose ]]; then
  printf '%s\n' "$choice"
  exit 0
fi
if [[ "\$1" == input ]]; then
  printf '%s\n' "$password"
  exit 0
fi
exit 1
EOF
  chmod +x "$dest"
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# already-up: ping works, never touch iwd
make_ping "$tmp/ping-ok" always-ok
make_iwctl "$tmp/iwctl-unused" no-radio
assert_exit 0 already-up \
  env NETWORK_PING="$tmp/ping-ok" NETWORK_IWCTL="$tmp/iwctl-unused" NETWORK_GUM="$tmp/missing" \
    NETWORK_SLEEP=true \
  "$NETWORK"
if [[ -f "$tmp/iwctl-unused.log" ]]; then
  echo "FAIL already-up: iwctl was invoked"
  failed=1
fi

# no radio
make_ping "$tmp/ping-fail" always-fail
make_iwctl "$tmp/iwctl-empty" no-radio
make_gum "$tmp/gum" HomeNet secret
assert_exit 1 no-radio \
  env NETWORK_PING="$tmp/ping-fail" NETWORK_IWCTL="$tmp/iwctl-empty" NETWORK_GUM="$tmp/gum" \
    NETWORK_SLEEP=true \
  "$NETWORK"

# connect then ping ok
make_ping "$tmp/ping-retry" fail-then-ok
make_iwctl "$tmp/iwctl-ok" one-station
make_gum "$tmp/gum-home" HomeNet secret
assert_exit 0 connect-then-ping-ok \
  env NETWORK_PING="$tmp/ping-retry" NETWORK_IWCTL="$tmp/iwctl-ok" NETWORK_GUM="$tmp/gum-home" \
    NETWORK_SLEEP=true \
  "$NETWORK"

# connect then ping fail
make_ping "$tmp/ping-still-down" always-fail
make_iwctl "$tmp/iwctl-ok2" one-station
make_gum "$tmp/gum-home2" HomeNet secret
assert_exit 1 connect-then-ping-fail \
  env NETWORK_PING="$tmp/ping-still-down" NETWORK_IWCTL="$tmp/iwctl-ok2" NETWORK_GUM="$tmp/gum-home2" \
    NETWORK_SLEEP=true \
  "$NETWORK"

# gum missing: fail closed with iwctl hint, no pacman
make_ping "$tmp/ping-down" always-fail
assert_contains gum-missing "iwctl" \
  env NETWORK_PING="$tmp/ping-down" NETWORK_IWCTL="$tmp/iwctl-ok" NETWORK_GUM="$tmp/no-such-gum" \
  "$NETWORK"

if ((failed)); then
  exit 1
fi
echo "all tests passed"
