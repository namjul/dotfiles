#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Stamp after success only — a getty respawn must not block a retry.
stamp="${ARCH_INSTALL_STAMP:-/run/arch-install-started}"
if [[ -f "$stamp" ]]; then
  exit 0
fi

boot=""
on_exit() {
  rm -f "$boot"
  if [[ ! -f "$stamp" ]]; then
    printf '%s\n' "To run the install again:  arch-install" >&2
  fi
}
trap on_exit EXIT

network=/usr/local/bin/arch-install-network
[[ -x "$network" ]] || network="$DIR/../network.sh"
"$network"

repo="${DOTFILES_REPO:-namjul/dotfiles}"
ref="${DOTFILES_REF:-master}"
url="https://raw.githubusercontent.com/${repo}/${ref}/bin/arch-install/boot.sh"

boot=$(mktemp)
# File, not a pipe: `curl | bash </dev/tty` starves curl (EPIPE).
"${ARCH_INSTALL_CURL:-curl}" -fsSL "$url" -o "$boot"

# `[[ -r /dev/tty ]]` can pass when opening it as stdin still fails.
if { : </dev/tty; } 2>/dev/null; then
  bash "$boot" </dev/tty
else
  bash "$boot"
fi

# /run is tmpfs — gone on reboot, so the next boot can start again.
touch "$stamp"
