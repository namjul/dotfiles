#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0

fail() {
  echo "FAIL $1"
  failed=1
}

ok() {
  echo "ok   $1"
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

releng="$tmp/releng"
mkdir -p "$releng/airootfs/root"
printf '%s\n' base iwd archinstall >"$releng/packages.x86_64"
cat >"$releng/profiledef.sh" <<'EOF'
#!/usr/bin/env bash
iso_name="archlinux"
iso_label="ARCH_202601"
file_permissions=(
  ["/root"]="0:0:750"
)
EOF
echo "~/.automated_script.sh" >"$releng/airootfs/root/.zlogin"

profile=$(
  env ARCHISO_RELENG="$releng" ARCHISO_PROFILE="$tmp/profile" \
    "$DIR/mkiso.sh" --prepare-only
)

if [[ "$profile" != "$tmp/profile" ]]; then
  fail "prepare-only prints profile path (got: $profile)"
else
  ok "prepare-only prints profile path"
fi

if grep -qx gum "$profile/packages.x86_64"; then
  ok "packages.x86_64 contains gum"
else
  fail "packages.x86_64 missing gum"
fi

if [[ -x "$profile/airootfs/usr/local/bin/arch-install-network" ]]; then
  ok "arch-install-network is executable"
else
  fail "arch-install-network missing or not executable"
fi

if [[ -x "$profile/airootfs/usr/local/bin/arch-install-start" ]]; then
  ok "arch-install-start is executable"
else
  fail "arch-install-start missing or not executable"
fi

if grep -Fq arch-install-start "$profile/airootfs/root/.zlogin"; then
  ok ".zlogin starts arch-install-start"
else
  fail ".zlogin missing arch-install-start"
fi

if grep -Fq 'iso_name="archlinux-dotfiles"' "$profile/profiledef.sh"; then
  ok "iso_name is archlinux-dotfiles"
else
  fail "iso_name not patched"
fi

if grep -Fq 'NAMJL_' "$profile/profiledef.sh"; then
  ok "iso_label uses NAMJL_"
else
  fail "iso_label not patched"
fi

if grep -Fq '/usr/local/bin/arch-install-network' "$profile/profiledef.sh"; then
  ok "file_permissions include network script"
else
  fail "file_permissions missing network script"
fi

if ((failed)); then
  exit 1
fi
echo "all tests passed"
