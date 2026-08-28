#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START="$DIR/iso/start.sh"
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

ping_ok() { return 0; }
ping_fail() { return 1; }
export -f ping_ok ping_fail

curl_ok() {
  local dest=""
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -o ]]; then
      dest="$2"
      shift 2
      continue
    fi
    shift
  done
  [[ -n "$dest" ]] || return 1
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' >"$dest"
}

curl_fail() {
  return 1
}

export -f curl_ok curl_fail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Already stamped: do not call the network gate (a failing ping would abort).
stamp="$tmpdir/started"
touch "$stamp"
assert_exit 0 already-stamped \
  env ARCH_INSTALL_STAMP="$stamp" NETWORK_PING=ping_fail "$START"
[[ -f "$stamp" ]] || {
  echo "FAIL already-stamped: stamp was removed"
  failed=1
}

# Failed or interrupted gate must not leave a stamp (wrong password, Ctrl+C).
stamp="$tmpdir/after-fail"
rm -f "$stamp"
assert_exit 1 failed-gate-leaves-no-stamp \
  env ARCH_INSTALL_STAMP="$stamp" NETWORK_PING=ping_fail NETWORK_GUM=/no/such/gum "$START"
if [[ -f "$stamp" ]]; then
  echo "FAIL failed-gate-leaves-no-stamp: stamp exists"
  failed=1
else
  echo "ok   failed-gate-leaves-no-stamp (no file)"
fi

# Fetch failure after a link must not stamp either.
stamp="$tmpdir/after-curl-fail"
rm -f "$stamp"
assert_exit 1 curl-fail-leaves-no-stamp \
  env ARCH_INSTALL_STAMP="$stamp" NETWORK_PING=ping_ok ARCH_INSTALL_CURL=curl_fail "$START"
if [[ -f "$stamp" ]]; then
  echo "FAIL curl-fail-leaves-no-stamp: stamp exists"
  failed=1
else
  echo "ok   curl-fail-leaves-no-stamp (no file)"
fi

# Success writes the stamp so a later getty respawn is a no-op.
stamp="$tmpdir/after-ok"
rm -f "$stamp"
assert_exit 0 success-stamps \
  env ARCH_INSTALL_STAMP="$stamp" NETWORK_PING=ping_ok ARCH_INSTALL_CURL=curl_ok "$START"
if [[ -f "$stamp" ]]; then
  echo "ok   success-stamps (file)"
else
  echo "FAIL success-stamps: stamp missing"
  failed=1
fi

if ((failed)); then
  exit 1
fi
echo "all tests passed"
