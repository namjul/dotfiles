#!/usr/bin/env bash
# mise description="SDDM for Sway login — PAM patch + enable (omarchy install/login/sddm.sh)"

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

if [[ -e /run/fig-test-container ]]; then
  sudo() { "$@"; }
fi

SWAY_SESSION="/usr/share/wayland-sessions/sway.desktop"

if ! pacman -Q sddm &>/dev/null; then
  echo "Install sddm first: mise r //aspects/aur:packages" >&2
  exit 1
fi

if [[ ! -f "${SWAY_SESSION}" ]]; then
  echo "Missing ${SWAY_SESSION} — install sway via //aspects/aur:packages" >&2
  exit 1
fi

if [[ ! -f /etc/pam.d/sddm ]]; then
  echo "Missing /etc/pam.d/sddm — reinstall sddm" >&2
  exit 1
fi

# Keep -session pam_gnome_keyring (SSH_AUTH_SOCK at login); drop -auth/-password.
# Password-based logins would create an encrypted login keyring conflicting with
# the passwordless Default_keyring (omarchy sddm.sh:32-35).
sudo sed -i '/-auth.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm

sudo systemctl enable sddm.service

echo "SDDM enabled (starts on next boot). Reboot, pick Sway at the greeter, then check SSH_AUTH_SOCK."
echo "Recovery: Ctrl+Alt+F2 → sudo systemctl disable --now sddm (see PLAN.sway.md step 16)"
