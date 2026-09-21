#!/usr/bin/env bash
# mise description="Base packages on SERVER (apt baseline)"

set -euo pipefail

packages="curl vim htop ufw git unzip gnupg acl mosh ncdu ca-certificates rsync ripgrep jq"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get full-upgrade -y
apt-get install -y $packages
apt-get autoremove -y
echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | debconf-set-selections
apt-get install -y unattended-upgrades

if [ -f /var/run/reboot-required ]; then
  echo 'NOTE: Reboot required after upgrades. Run: mise run reboot-if-required'
  cat /var/run/reboot-required 2>/dev/null || true
fi
