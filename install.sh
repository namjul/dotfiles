#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sfn "$DOTFILES" "$HOME/.dotfiles"
cd "$HOME/.dotfiles"

if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

mise install --yes

# sudo -v caches on this TTY; MISE_RAW keeps a later prompt usable after the timestamp expires
sudo -v
export MISE_RAW=1

mise run //aspects/nala:default
mise run //aspects/homebrew:default
mise run //aspects/aur:default
mise run //aspects/dotfiles:default
mise run //aspects/shell:default
mise run //aspects/nvim:default
mise run //aspects/fonts:default
mise run //aspects/interception:default
mise run //aspects/systemd:default

touch /var/tmp/omarchy-install-completed

# mise doctor

echo "The following mise tasks are available:"
mise t --all

