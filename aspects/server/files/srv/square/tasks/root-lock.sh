#!/usr/bin/env bash
# mise description="Lock root console password (after key-based SSH works)"

set -euo pipefail

passwd -l root
