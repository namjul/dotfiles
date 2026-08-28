#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$DIR/network.sh"

if [[ "${SKIP_CONFIGURE:-}" != 1 ]]; then
  "$DIR/configure.sh"
fi

sed -i \
  -e 's|logfile_target = self\.target / absolute_logfile$|logfile_target = self.target / absolute_logfile.relative_to("/")|' \
  -e 's|(limine_path / file)\.copy(efi_dir_path)|(limine_path / file).copy(efi_dir_path / file)|' \
  -e "s|(limine_path / 'limine-bios.sys')\.copy(boot_limine_path)|(limine_path / 'limine-bios.sys').copy(boot_limine_path / 'limine-bios.sys')|" \
  /usr/lib/python3.14/site-packages/archinstall/lib/installer.py 2>/dev/null || true

args=(
  --config "$DIR/user_configuration.json"
  --creds "$DIR/user_credentials.json"
)
if [[ "${INTERACTIVE:-}" != 1 ]] &&
  jq -e '.disk_config.config_type == "default_layout"' "$DIR/user_configuration.json" >/dev/null; then
  args+=(--silent)
fi

archinstall "${args[@]}"
