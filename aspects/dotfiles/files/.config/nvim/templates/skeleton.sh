#!/bin/bash

# https://github.com/guettli/programming-guidelines?tab=readme-ov-file#shell-scripts-are-ok-if-
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail
