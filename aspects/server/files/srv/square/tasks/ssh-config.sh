#!/usr/bin/env bash
# mise description="Deploy sshd_config if changed and restart ssh"

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
CFG="$ROOT/config/sshd_config"

if diff -q /etc/ssh/sshd_config "$CFG" >/dev/null 2>&1; then
  exit 0
fi

cp "$CFG" /etc/ssh/sshd_config
systemctl restart ssh.service
