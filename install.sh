#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# sudo -v caches on this TTY; the loop refreshes it so later sudo calls do not re-ask.
# MISE_RAW keeps a prompt usable if the stamp still dies.
sudo -v
export MISE_RAW=1
keep_sudo() {
  while kill -0 "$$" 2>/dev/null; do
    sleep 60
    sudo -n true || exit
  done
}
keep_sudo &
sudo_keepalive_pid=$!
trap 'kill "$sudo_keepalive_pid" 2>/dev/null || true' EXIT

mise install --yes

# package managers (each no-ops off-platform)
mise run //aspects/nala:default
mise run //aspects/homebrew:default
mise run //aspects/aur:default

# home: links, fish, nvim, fonts
mise run //aspects/dotfiles:default
mise run //aspects/shell:default
mise run //aspects/nvim:default
mise run //aspects/fonts:default

# linux input remap + user units
mise run //aspects/interception:default
mise run //aspects/systemd:default

mise doctor

touch /var/tmp/namarchy-install-completed

echo "The following mise tasks are available:"
mise t --all

