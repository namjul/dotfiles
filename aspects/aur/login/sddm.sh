#!/usr/bin/env bash
# mise description="SDDM login — PAM patch, niri autologin (omarchy install/login/sddm.sh)"

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

LOCAL_NIRI_SESSION="/usr/local/share/wayland-sessions/niri.desktop"

if ! pacman -Q sddm &>/dev/null; then
  echo "Install sddm first: mise r //aspects/aur:packages" >&2
  exit 1
fi

if ! command -v uwsm >/dev/null; then
  echo "Install uwsm first: mise r //aspects/aur:packages" >&2
  exit 1
fi

if ! pacman -Q niri &>/dev/null; then
  echo "Install niri first: mise r //aspects/aur:packages" >&2
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

# LUKS is the boot gate; after unlock, SDDM starts niri via UWSM as this user.
# Exec is a command on PATH (uwsm), not a clone path.
sudo mkdir -p /etc/sddm.conf.d /usr/local/share/wayland-sessions
cat <<EOF | sudo tee "${LOCAL_NIRI_SESSION}" >/dev/null
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=uwsm start -- niri --session
Type=Application
DesktopNames=niri
EOF
cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null
[Autologin]
User=${USER}
Session=niri
EOF

sudo systemctl enable sddm.service

echo "SDDM autologin to niri (UWSM) as ${USER} (starts on next boot)."
echo "Recovery: Ctrl+Alt+F2 → sudo systemctl disable --now sddm → uwsm start -- niri --session"
