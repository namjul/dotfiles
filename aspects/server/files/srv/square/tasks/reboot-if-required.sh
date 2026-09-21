#!/usr/bin/env bash
# mise description="Reboot SERVER only if /var/run/reboot-required exists"

set -euo pipefail

if [ ! -f /var/run/reboot-required ]; then
  echo "No reboot required"
  exit 0
fi

cat /var/run/reboot-required 2>/dev/null || true
echo "Rebooting..."
nohup systemctl reboot >/dev/null 2>&1 &
sleep 1
