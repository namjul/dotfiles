#!/usr/bin/env bash
# mise description="Tailscale status and tailnet IPv4 on SERVER"

set -euo pipefail

tailscale status
tailscale ip -4
