#!/usr/bin/env bash
# mise description="SDDM PAM patch (omarchy install/login/sddm.sh:32-35)"

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

if [[ -e /run/fig-test-container ]]; then
  sudo() { "$@"; }
fi

if [[ ! -f /etc/pam.d/sddm ]]; then
  echo "Skipping SDDM PAM patch — /etc/pam.d/sddm not found (install sddm via //aspects/aur:packages first)" >&2
  exit 0
fi

# Keep -session pam_gnome_keyring (SSH_AUTH_SOCK at login); drop -auth/-password.
# Password-based logins would create an encrypted login keyring conflicting with
# the passwordless Default_keyring (omarchy sddm.sh:32-35).
sudo sed -i '/-auth.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
