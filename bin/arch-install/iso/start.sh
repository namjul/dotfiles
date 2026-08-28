#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Live getty can respawn after a successful run; stamp only then so a failed
# password or Ctrl+C can retry without a manual rm.
stamp="${ARCH_INSTALL_STAMP:-/run/arch-install-started}"
if [[ -f "$stamp" ]]; then
  exit 0
fi

network=/usr/local/bin/arch-install-network
[[ -x "$network" ]] || network="$DIR/../network.sh"
"$network"

repo="${DOTFILES_REPO:-namjul/dotfiles}"
ref="${DOTFILES_REF:-master}"
url="https://raw.githubusercontent.com/${repo}/${ref}/bin/arch-install/boot.sh"

boot=$(mktemp)
# File, not a pipe: `curl | bash </dev/tty` points bash at the TTY and curl
# gets EPIPE ("Failed writing body"). Same pattern as boot.sh run_next.
trap 'rm -f "$boot"' EXIT
"${ARCH_INSTALL_CURL:-curl}" -fsSL "$url" -o "$boot"

if { : </dev/tty; } 2>/dev/null; then
  bash "$boot" </dev/tty
else
  bash "$boot"
fi

# /run is tmpfs — the stamp dies on reboot so a new boot can start again.
touch "$stamp"
