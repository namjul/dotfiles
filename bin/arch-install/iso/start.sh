#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Live getty can respawn; without this the start script would curl again on every login.
stamp="${ARCH_INSTALL_STAMP:-/run/arch-install-started}"
if [[ -f "$stamp" ]]; then
  exit 0
fi
# /run is tmpfs — the stamp dies on reboot so a new boot can start again.
touch "$stamp"

network=/usr/local/bin/arch-install-network
[[ -x "$network" ]] || network="$DIR/../network.sh"
"$network"

repo="${DOTFILES_REPO:-namjul/dotfiles}"
ref="${DOTFILES_REF:-master}"
url="https://raw.githubusercontent.com/${repo}/${ref}/bin/arch-install/boot.sh"

# curl | bash leaves stdin on the pipe; gum in boot.sh needs the real TTY.
if [[ -r /dev/tty ]]; then
  curl -fsSL "$url" | bash </dev/tty
else
  curl -fsSL "$url" | bash
fi
