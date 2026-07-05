#!/usr/bin/env bash
# mise description="Passwordless gnome-keyring default keyring (omarchy install/login/default-keyring.sh)"

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

KEYRING_DIR="${HOME}/.local/share/keyrings"
KEYRING_FILE="${KEYRING_DIR}/Default_keyring.keyring"
DEFAULT_FILE="${KEYRING_DIR}/default"

mkdir -p "${KEYRING_DIR}"

cat <<EOF >"${KEYRING_FILE}"
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF

cat <<EOF >"${DEFAULT_FILE}"
Default_keyring
EOF

chmod 700 "${KEYRING_DIR}"
chmod 600 "${KEYRING_FILE}"
chmod 644 "${DEFAULT_FILE}"
