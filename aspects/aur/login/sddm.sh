#!/usr/bin/env bash
# mise description="SDDM for Sway login — PAM patch + enable (omarchy install/login/sddm.sh)"

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

SWAY_SESSION="/usr/share/wayland-sessions/sway.desktop"
# /usr/local wins SDDM SessionDir so we keep Session=sway without editing pacman's desktop file.
LOCAL_SESSION="/usr/local/share/wayland-sessions/sway.desktop"

if ! pacman -Q sddm &>/dev/null; then
  echo "Install sddm first: mise r //aspects/aur:packages" >&2
  exit 1
fi

if ! command -v uwsm >/dev/null; then
  echo "Install uwsm first: mise r //aspects/aur:packages" >&2
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
if [[ -f /etc/pam.d/sddm-autologin ]]; then
  sudo sed -i '/-auth.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm-autologin
  sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm-autologin
fi

# LUKS is the boot gate; after unlock, SDDM starts Sway via UWSM as this user.
# Exec is a command on PATH (uwsm), not a clone path. uwsm start -- sway is the compositor binary.
sudo mkdir -p /etc/sddm.conf.d /usr/local/share/wayland-sessions
cat <<EOF | sudo tee "${LOCAL_SESSION}" >/dev/null
[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=uwsm start -- sway
Type=Application
DesktopNames=sway;wlroots
EOF
cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null
[Autologin]
User=${USER}
Session=sway
EOF

sudo systemctl enable sddm.service

echo "SDDM autologin to Sway (UWSM) as ${USER} (starts on next boot). Check SSH_AUTH_SOCK."
echo "Recovery: Ctrl+Alt+F2 → sudo systemctl disable --now sddm (see aspects/aur/PLAN.md)"
