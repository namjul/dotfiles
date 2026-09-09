#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
exec python3 "$root/vendor/spaced-inbox/spaced_inbox.py" "$@"
