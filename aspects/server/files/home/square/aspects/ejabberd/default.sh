#!/usr/bin/env bash

# https://github.com/guettli/bash-strict-mode
trap 'echo "Warning: A command has failed. Exiting the script. Line was ($0:$LINENO): $(sed -n "${LINENO}p" "$0")"; exit 3' ERR
set -Eeuo pipefail

sudo nala install -y ejabberd

sudo cp ${root}/ejabberd.yml /etc/ejabberd/ejabberd.yml

sudo systemctl daemon-reload
sudo systemctl enable ejabberd.service
sudo systemctl restart ejabberd.service
