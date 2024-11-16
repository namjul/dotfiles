#!/bin/bash

set -euxo pipefail

ufw default deny incoming
ufw default allow outgoing
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 6443
ufw allow 23231
ufw enable
ufw status verbose
