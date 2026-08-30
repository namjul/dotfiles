#!/usr/bin/env bash
set -euo pipefail

# Rate the live ISO mirrorlist before configure/archinstall. archinstall copies
# those Server= URLs into the target via configure.sh custom_servers.

if [[ "${SKIP_REFLECTOR:-}" == 1 ]]; then
  exit 0
fi

if ! command -v reflector >/dev/null; then
  pacman -Sy --noconfirm --needed reflector
fi

printf '%s\n' "Rating pacman mirrors (Germany, HTTPS)..." >&2
if ! reflector \
  --country Germany \
  --age 12 \
  --protocol https \
  --latest 15 \
  --number 10 \
  --sort rate \
  --download-timeout 5 \
  --save /etc/pacman.d/mirrorlist; then
  printf '%s\n' "reflector failed; keeping the existing mirrorlist." >&2
fi
