#!/usr/bin/env bash
set -euo pipefail

REPO="${DOTFILES_REPO:-namjul/dotfiles}"
REF="${DOTFILES_REF:-master}"

ansi_art='                              ▄▄▄
 ██▄   ▄██    ▄███████   ▄███████████▄     ▄███████    ▄███████   ▄███████   ▄█   █▄     ▄█   █▄
 ████  ███   ███   ███  ███   ███   ███   ███   ███   ███   ███  ███   ███  ███   ███   ███   ███
 ███ █ ███   ███   ███  ███   ███   ███   ███   ███   ███   ███  ███   █▀   ███   ███   ███   ███
 ███  ████  ▄███▄▄▄███  ███   ███   ███  ▄███▄▄▄███  ▄███▄▄▄██▀  ███        ███▄▄▄███▄  ███▄▄▄███
 ███   ███  ▀███▀▀▀███  ███   ███   ███  ▀███▀▀▀███  ▀███▀▀▀▀    ███        ███▀▀▀███   ▀▀▀▀▀▀███
 ███   ███   ███   ███  ███   ███   ███   ███   ███  ██████████  ███   █▄   ███   ███   ▄██   ███
 ███   ███   ███   ███  ███   ███   ███   ███   ███   ███   ███  ███   ███  ███   ███   ███   ███
 ███   ███   ███   █▀    ▀█   ███   █▀    ███   █▀    ███   ███  ███████▀   ███   █▀     ▀█████▀
                                                      ███   █▀'

clear
echo -e "\n$ansi_art\n"

is_live_iso() {
  [[ -d /run/archiso ]]
}

need_git() {
  command -v git >/dev/null && return
  if [[ $(id -u) -eq 0 ]]; then
    pacman -Sy --noconfirm --needed git
  else
    sudo pacman -Sy --noconfirm --needed git
  fi
}

ensure_repo() {
  local dest="$1"
  if [[ -d "$dest/.git" ]]; then
    echo "Using existing clone at $dest (branch $REF)"
    git -C "$dest" fetch origin "$REF"
    git -C "$dest" checkout "$REF"
    git -C "$dest" pull --ff-only origin "$REF"
    return
  fi
  if [[ -e "$dest" ]]; then
    echo "Refusing to overwrite $dest" >&2
    exit 1
  fi
  echo "Cloning https://github.com/${REPO}.git ($REF) → $dest"
  git clone --branch "$REF" "https://github.com/${REPO}.git" "$dest"
}

# curl | bash leaves stdin on the pipe; gum and sudo need the TTY
run_next() {
  local script="$1"
  if [[ -r /dev/tty ]]; then
    exec "$script" </dev/tty
  fi
  exec "$script"
}

need_git

if is_live_iso; then
  dest=/root/dotfiles
  ensure_repo "$dest"
  echo "Live ISO → arch-install"
  run_next "$dest/bin/arch-install/arch-install.sh"
fi

if [[ $(id -u) -eq 0 ]]; then
  echo "After reboot, run this as your user, not root." >&2
  exit 1
fi

dest="${DOTFILES_DIR:-$HOME/.dotfiles}"
ensure_repo "$dest"
echo "Installed system → install.sh"
run_next "$dest/install.sh"
