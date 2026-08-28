#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$DIR/../.." && pwd)"
PROFILE="${ARCHISO_PROFILE:-$DIR/work/profile}"
WORK="${ARCHISO_WORK:-$DIR/work/mkarchiso}"
OUT="${ARCHISO_OUT:-$DIR/out}"
prepare_only=0
[[ "${1:-}" == --prepare-only ]] && prepare_only=1

releng_src() {
  if [[ -n "${ARCHISO_RELENG:-}" && -d "$ARCHISO_RELENG" ]]; then
    printf '%s\n' "$ARCHISO_RELENG"
    return 0
  fi
  if [[ -d /usr/share/archiso/configs/releng ]]; then
    printf '%s\n' /usr/share/archiso/configs/releng
    return 0
  fi
  return 1
}

enter_container() {
  local engine
  if command -v docker >/dev/null 2>&1; then
    engine=docker
  elif command -v podman >/dev/null 2>&1; then
    engine=podman
  else
    echo "Need docker or podman to build on a non-Arch host." >&2
    exit 1
  fi
  local flags=(--rm --privileged -v "$REPO:/work" -w /work -e ARCHISO_IN_CONTAINER=1)
  # mkarchiso mounts loop devices; without privilege the squashfs build fails.
  # -t only when we have a TTY so CI / --prepare-only still work.
  if [[ -t 0 ]]; then
    flags+=(-it)
  else
    flags+=(-i)
  fi
  # Re-enter this same script on Arch; the overlay + mkarchiso body is unchanged.
  exec "$engine" run "${flags[@]}" archlinux:latest \
    /work/bin/arch-install/mkiso.sh "$@"
}

prepare() {
  local src="$1"
  rm -rf "$PROFILE"
  mkdir -p "$(dirname "$PROFILE")"
  cp -a "$src" "$PROFILE"
  printf '\n' >>"$PROFILE/packages.x86_64"
  cat "$DIR/iso/packages.append" >>"$PROFILE/packages.x86_64"
  install -Dm755 "$DIR/network.sh" "$PROFILE/airootfs/usr/local/bin/arch-install-network"
  install -Dm755 "$DIR/iso/start.sh" "$PROFILE/airootfs/usr/local/bin/arch-install-start"
  cat "$DIR/iso/zlogin.append" >>"$PROFILE/airootfs/root/.zlogin"

  sed -i 's/^iso_name=.*/iso_name="archlinux-dotfiles"/' "$PROFILE/profiledef.sh"
  sed -i 's/iso_label="ARCH_/iso_label="NAMJL_/' "$PROFILE/profiledef.sh"
  # archiso copies airootfs files as root:root 644 unless listed here.
  sed -i '/^file_permissions=(/a\
  ["/usr/local/bin/arch-install-network"]="0:0:755"\
  ["/usr/local/bin/arch-install-start"]="0:0:755"
' "$PROFILE/profiledef.sh"
}

src=""
if src=$(releng_src); then
  :
elif [[ -z "${ARCHISO_IN_CONTAINER:-}" ]]; then
  enter_container "$@"
else
  pacman -Sy --noconfirm --needed archiso
  src=/usr/share/archiso/configs/releng
fi

prepare "$src"

if ((prepare_only)); then
  printf '%s\n' "$PROFILE"
  exit 0
fi

if ! command -v mkarchiso >/dev/null 2>&1; then
  if [[ -z "${ARCHISO_IN_CONTAINER:-}" ]]; then
    enter_container "$@"
  fi
  pacman -Sy --noconfirm --needed archiso
fi

mkdir -p "$OUT" "$WORK"
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
