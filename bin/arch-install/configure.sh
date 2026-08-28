#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOT_OBJ="07ad4e87-5f4a-4110-a401-2ffa8e8603b6"
ROOT_OBJ="036761c7-d363-4391-9ec3-f8d3815c6523"
DEFAULT_KEYBOARD=de
DEFAULT_USERNAME=nam
DEFAULT_HOSTNAME=namarchy
DEFAULT_TIMEZONE=Europe/Vienna

abort() {
  gum style "${1:-Aborted}"
  exit 1
}

need_pkgs() {
  local missing=()
  local pkg
  for pkg in gum jq openssl; do
    command -v "$pkg" >/dev/null || missing+=("$pkg")
  done
  if ((${#missing[@]})); then
    pacman -Sy --noconfirm --needed "${missing[@]}"
  fi
}

step() {
  clear
  if [[ -f "$DIR/../../logo.txt" ]]; then
    cat "$DIR/../../logo.txt"
    echo
  fi
  gum style "$1"
  echo
}

list_keymaps() {
  local maps=""
  if maps=$(localectl list-keymaps 2>/dev/null) && [[ -n "$maps" ]]; then
    printf '%s\n' "$maps"
    return 0
  fi
  if [[ -d /usr/share/kbd/keymaps ]]; then
    maps=$(
      find /usr/share/kbd/keymaps -type f \( -name '*.map' -o -name '*.map.gz' -o -name '*.kmap' -o -name '*.kmap.gz' \) -printf '%f\n' |
        sed -E 's/\.(map|kmap)(\.gz)?$//' |
        sort -u
    )
    if [[ -n "$maps" ]]; then
      printf '%s\n' "$maps"
      return 0
    fi
  fi
  printf '%s\n' de us uk fr it es dvorak colemak
}

keyboard_form() {
  step "Keyboard"
  local maps
  maps=$(list_keymaps)
  keyboard=$(printf '%s\n' "$maps" | gum filter --height 12 --header "Keyboard layout" --value "$DEFAULT_KEYBOARD") || abort
  if [[ $(tty 2>/dev/null) == /dev/tty* ]]; then
    loadkeys "$keyboard" 2>/dev/null || true
  fi
}

user_form() {
  step "User"
  while true; do
    username=$(gum input --placeholder "like $DEFAULT_USERNAME" --prompt "Username> " --value "${username:-$DEFAULT_USERNAME}") || abort
    if [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
      break
    fi
    gum style "Username must be lowercase alphanumeric"
  done

  while true; do
    password=$(gum input --password --prompt "Password> ") || abort
    password_confirmation=$(gum input --password --prompt "Confirm> ") || abort
    if [[ -n "$password" && "$password" == "$password_confirmation" ]]; then
      break
    fi
    gum style "Password empty or mismatch"
  done

  hostname=$(gum input --placeholder "$DEFAULT_HOSTNAME" --prompt "Hostname> " --value "${hostname:-$DEFAULT_HOSTNAME}") || abort
  if [[ -z "$hostname" ]]; then
    hostname=$DEFAULT_HOSTNAME
  fi
  if [[ ! "$hostname" =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]]; then
    abort "Bad hostname"
  fi

  local guess
  guess=$(timedatectl show -p Timezone --value 2>/dev/null || true)
  [[ -n "$guess" ]] || guess=$DEFAULT_TIMEZONE
  timezone=$(timedatectl list-timezones | gum filter --height 12 --header "Timezone" --value "$guess") || abort
}

get_root_disk() {
  local device="$1"
  local parent
  [[ -n $device ]] || return 1
  device=$(readlink -f "$device" 2>/dev/null || printf '%s\n' "$device")
  while true; do
    parent=$(lsblk -dno PKNAME "$device" 2>/dev/null | tail -n1)
    [[ -n $parent ]] || break
    device="/dev/$parent"
  done
  if [[ $(lsblk -dno TYPE "$device" 2>/dev/null) == disk ]]; then
    printf '%s\n' "$device"
  fi
}

disk_info() {
  local device="$1"
  local size vendor model label
  size=$(lsblk -dno SIZE "$device" 2>/dev/null)
  vendor=$(lsblk -dno VENDOR "$device" 2>/dev/null | sed 's/ *$//')
  model=$(lsblk -dno MODEL "$device" 2>/dev/null | sed 's/ *$//')
  label=""
  if [[ -n $vendor && -n $model ]]; then
    if [[ $model == *$vendor* ]]; then
      label="$model"
    else
      label="$vendor $model"
    fi
  elif [[ -n $model ]]; then
    label="$model"
  elif [[ -n $vendor ]]; then
    label="$vendor"
  fi
  local display="$device"
  [[ -n $size ]] && display="$display ($size)"
  [[ -n $label ]] && display="$display - $label"
  printf '%s\n' "$display"
}

disk_form() {
  step "Install disk"
  local boot_source exclude_disk available_disks disk_options selected
  boot_source=$(findmnt -no SOURCE /run/archiso/bootmnt 2>/dev/null || true)
  exclude_disk=$(get_root_disk "$boot_source" || true)

  available_disks=$(
    lsblk -dpno NAME,TYPE |
      awk '$2=="disk"{print $1}' |
      grep -E '/dev/(sd|hd|vd|nvme|mmcblk|xv)' |
      { if [[ -n "$exclude_disk" ]]; then grep -Fvx "$exclude_disk"; else cat; fi; }
  )

  disk_options=""
  while IFS= read -r device; do
    [[ -n "$device" ]] || continue
    disk_options+="$(disk_info "$device")"$'\n'
  done <<<"$available_disks"

  [[ -n "$disk_options" ]] || abort "No installable disks"
  selected=$(printf '%s' "$disk_options" | gum choose --header "Select install disk") || abort
  disk=$(awk '{print $1}' <<<"$selected")
}

confirm_disk() {
  local mode=encrypted
  local affirmative status
  while true; do
    step "Overwrite ${disk}"
    gum style "Everything on ${disk} will be wiped."
    if [[ $mode == encrypted ]]; then
      gum style --foreground 8 "Ctrl+C: install without LUKS"
      affirmative="Yes, LUKS"
    else
      affirmative="Yes, no LUKS"
    fi
    echo
    set +e
    gum confirm --affirmative "$affirmative" --negative "Change disk" "Confirm overwrite"
    status=$?
    set -e
    case $status in
      0)
        [[ $mode == encrypted ]] && encrypt=true || encrypt=false
        return 0
        ;;
      1)
        return 1
        ;;
      130)
        if [[ $mode == encrypted ]]; then
          mode=unencrypted
        else
          mode=encrypted
        fi
        ;;
      *)
        abort
        ;;
    esac
  done
}

review() {
  step "Review"
  printf '%s\n' \
    "Username,${username}" \
    "Hostname,${hostname}" \
    "Timezone,${timezone}" \
    "Keyboard,${keyboard}" \
    "Disk,${disk}" \
    "LUKS,${encrypt}" |
    gum table -s "," -p
  echo
  gum confirm "Does this look right?" || return 1
}

write_json() {
  local password_hash disk_size mib gib boot_start boot_size root_start root_size
  password_hash=$(printf '%s' "$password" | openssl passwd -6 -stdin)

  mib=$((1024 * 1024))
  gib=$((mib * 1024))
  disk_size=$(lsblk -bdno SIZE "$disk")
  disk_size=$((disk_size / mib * mib))
  boot_start=$mib
  boot_size=$gib
  root_start=$((boot_start + boot_size))
  root_size=$((disk_size - root_start - mib))

  jq -n \
    --arg user "$username" \
    --arg hash "$password_hash" \
    --argjson encrypt "$encrypt" \
    --arg pass "$password" \
    '{
      root_enc_password: $hash,
      users: [{ enc_password: $hash, groups: [], sudo: true, username: $user }]
    } + (if $encrypt then { encryption_password: $pass } else {} end)' \
    >"$DIR/user_credentials.json"

  jq -n \
    --arg disk "$disk" \
    --arg hostname "$hostname" \
    --arg timezone "$timezone" \
    --arg keyboard "$keyboard" \
    --arg boot_obj "$BOOT_OBJ" \
    --arg root_obj "$ROOT_OBJ" \
    --argjson boot_start "$boot_start" \
    --argjson boot_size "$boot_size" \
    --argjson root_start "$root_start" \
    --argjson root_size "$root_size" \
    --argjson encrypt "$encrypt" \
    --arg pass "$password" \
    --arg m1 'https://mirror.rackspace.com/archlinux/$repo/os/$arch' \
    --arg m2 'https://geo.mirror.pkgbuild.com/$repo/os/$arch' \
    '{
      app_config: { audio_config: { audio: "pipewire" } },
      "archinstall-language": "English",
      auth_config: {},
      bootloader_config: { bootloader: "Limine", removable: true, uki: false },
      custom_commands: [],
      disk_config: {
        btrfs_options: { snapshot_config: null },
        config_type: "default_layout",
        device_modifications: [{
          device: $disk,
          partitions: [
            {
              btrfs: [],
              dev_path: null,
              flags: ["boot"],
              fs_type: "fat32",
              mount_options: [],
              mountpoint: "/boot",
              obj_id: $boot_obj,
              size: { sector_size: { unit: "B", value: 512 }, unit: "B", value: $boot_size },
              start: { sector_size: { unit: "B", value: 512 }, unit: "B", value: $boot_start },
              status: "create",
              type: "primary"
            },
            {
              btrfs: [],
              dev_path: null,
              flags: [],
              fs_type: "ext4",
              mount_options: [],
              mountpoint: "/",
              obj_id: $root_obj,
              size: { sector_size: { unit: "B", value: 512 }, unit: "B", value: $root_size },
              start: { sector_size: { unit: "B", value: 512 }, unit: "B", value: $root_start },
              status: "create",
              type: "primary"
            }
          ],
          wipe: true
        }]
      },
      hostname: $hostname,
      kernels: ["linux"],
      locale_config: { kb_layout: $keyboard, sys_enc: "UTF-8", sys_lang: "en_US.UTF-8" },
      mirror_config: {
        custom_repositories: [],
        custom_servers: [
          { url: $m1 },
          { url: $m2 }
        ],
        mirror_regions: {},
        optional_repositories: []
      },
      network_config: { type: "iso" },
      ntp: true,
      packages: ["base-devel", "git"],
      pacman_config: { color: true, parallel_downloads: 8 },
      profile_config: { gfx_driver: null, greeter: null, profile: {} },
      script: null,
      services: [],
      swap: { algorithm: "zstd", enabled: true },
      timezone: $timezone,
      version: "4.3"
    } | if $encrypt then
      .disk_config.disk_encryption = {
        encryption_type: "luks",
        lvm_volumes: [],
        iter_time: 2000,
        partitions: [$root_obj],
        encryption_password: $pass
      }
    else . end' \
    >"$DIR/user_configuration.json"
}

need_pkgs
keyboard_form
user_form
disk_form
while ! confirm_disk; do
  disk_form
done
until review; do
  keyboard_form
  user_form
  disk_form
  while ! confirm_disk; do
    disk_form
  done
done
write_json
