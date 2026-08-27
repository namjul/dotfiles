#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# sudo -v caches on this TTY; MISE_RAW keeps a later prompt usable after the timestamp expires
sudo -v
export MISE_RAW=1

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

