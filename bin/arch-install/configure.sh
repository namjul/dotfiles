#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOT_OBJ="07ad4e87-5f4a-4110-a401-2ffa8e8603b6"
ROOT_OBJ="036761c7-d363-4391-9ec3-f8d3815c6523"
EFI_GUID=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
MSR_GUID=e3c9e316-0b5c-4db8-817d-f92df00215ae
LINUX_GUIDS='0fc63daf-8483-4772-8e79-3d69d8477de4 4f68bce3-e8cd-4db1-96e7-fbcaf984b709 ca7d7ccb-63ed-4c53-861c-1742536059cc 0657fd6d-a4ab-43c4-84e5-0933c84b4f4f'
DEFAULT_KEYBOARD=de
DEFAULT_USERNAME=nam
DEFAULT_HOSTNAME=namarchy
DEFAULT_TIMEZONE=Europe/Vienna
disk_mode=erase
encrypt=false

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
  command -v sgdisk >/dev/null || missing+=("gptfdisk")
  if ((${#missing[@]})); then
    pacman -Sy --noconfirm --needed "${missing[@]}"
  fi
}

step() {
  clear
  if [[ -f "$DIR/logo.txt" ]]; then
    cat "$DIR/logo.txt"
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

part_kind() {
  local fstype="${1,,}"
  local parttype="${2,,}"
  if [[ $parttype == "$EFI_GUID" ]]; then
    printf '%s\n' keep-efi
    return
  fi
  if [[ $parttype == "$MSR_GUID" ]]; then
    printf '%s\n' keep-msr
    return
  fi
  if [[ $fstype == ntfs || $fstype == bitlocker ]]; then
    printf '%s\n' keep-windows
    return
  fi
  case $fstype in
    ext4 | btrfs | xfs | swap | crypto_luks)
      printf '%s\n' linux
      return
      ;;
  esac
  if [[ " $LINUX_GUIDS " == *" $parttype "* ]]; then
    printf '%s\n' linux
    return
  fi
  printf '%s\n' unknown
}

part_number() {
  local name="$1"
  if [[ $name =~ p([0-9]+)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  elif [[ $name =~ ([0-9]+)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  fi
}

each_partition() {
  local name ptype size fstype parttype kind path
  while read -r name ptype; do
    [[ $ptype == part ]] || continue
    path="/dev/${name#/dev/}"
    size=$(lsblk -nro SIZE "$path")
    fstype=$(lsblk -nro FSTYPE "$path")
    parttype=$(lsblk -nro PARTTYPE "$path")
    kind=$(part_kind "$fstype" "$parttype")
    printf '%s %s %s %s\n' "$name" "$size" "${fstype:-none}" "$kind"
  done < <(lsblk -nro NAME,TYPE "$disk")
}

show_partition_table() {
  local rows
  rows=$(
    echo "Name,Size,FS,Kind"
    each_partition | awk '{printf "%s,%s,%s,%s\n", $1, $2, $3, $4}'
  )
  printf '%s\n' "$rows" | gum table -s "," -p
}

linux_partition_names() {
  each_partition | awk '$4=="linux"{print $1}'
}

delete_linux_partition() {
  local name="$1"
  local kind number
  kind=$(each_partition | awk -v n="$name" '$1==n{print $4}')
  [[ $kind == linux ]] || abort "Refusing to delete $name ($kind)"
  number=$(part_number "$name")
  [[ -n $number ]] || abort "No partition number for $name"
  sgdisk --delete="$number" "$disk"
  partprobe "$disk" 2>/dev/null || true
}

partition_help() {
  local names selected typed
  step "Linux partitions on ${disk}"
  gum style "Labels are guesses. EFI, Windows, and MSR are not offered."
  echo
  show_partition_table
  echo
  while true; do
    names=$(linux_partition_names)
    if [[ -z $names ]]; then
      gum style "No linux partitions labeled. Continue to the TUI."
      gum confirm "Continue?" || abort
      return 0
    fi
    selected=$(printf '%s\n' $names Done | gum choose --header "Delete a linux partition, or Done") || abort
    if [[ $selected == Done ]]; then
      return 0
    fi
    typed=$(gum input --prompt "Type $selected to delete> ") || abort
    if [[ $typed != "$selected" ]]; then
      gum style "Name mismatch. Not deleted."
      continue
    fi
    delete_linux_partition "$selected"
    step "Linux partitions on ${disk}"
    show_partition_table
    echo
  done
}

install_mode_form() {
  step "Disk mode"
  local selected
  selected=$(
    gum choose --header "How to use ${disk}" \
      "Erase entire disk" \
      "Leave disk to archinstall TUI"
  ) || abort
  case $selected in
    "Erase entire disk")
      disk_mode=erase
      ;;
    *)
      disk_mode=tui
      encrypt=false
      ;;
  esac
}

collect_disk() {
  disk_form
  install_mode_form
  if [[ $disk_mode == erase ]]; then
    while ! confirm_disk; do
      disk_form
      install_mode_form
      if [[ $disk_mode == tui ]]; then
        partition_help
        return 0
      fi
    done
    return 0
  fi
  partition_help
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
  local disk_review luks_review
  if [[ $disk_mode == tui ]]; then
    disk_review="archinstall TUI (${disk})"
    luks_review="set in TUI"
  else
    disk_review=$disk
    luks_review=$encrypt
  fi
  step "Review"
  printf '%s\n' \
    "Username,${username}" \
    "Hostname,${hostname}" \
    "Timezone,${timezone}" \
    "Keyboard,${keyboard}" \
    "Disk,${disk_review}" \
    "LUKS,${luks_review}" |
    gum table -s "," -p
  echo
  if [[ $disk_mode == tui ]]; then
    gum style "In the TUI set Disk (existing EFI as /boot, hole as /) before Install."
    echo
  fi
  gum confirm "Does this look right?" || return 1
}

write_creds() {
  local password_hash
  password_hash=$(printf '%s' "$password" | openssl passwd -6 -stdin)
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
}

write_json() {
  local disk_size mib gib boot_start boot_size root_start root_size
  write_creds

  if [[ $disk_mode == tui ]]; then
    jq -n \
      --arg hostname "$hostname" \
      --arg timezone "$timezone" \
      --arg keyboard "$keyboard" \
      --arg m1 'https://mirror.rackspace.com/archlinux/$repo/os/$arch' \
      --arg m2 'https://geo.mirror.pkgbuild.com/$repo/os/$arch' \
      '{
        app_config: { audio_config: { audio: "pipewire" } },
        "archinstall-language": "English",
        auth_config: {},
        bootloader_config: { bootloader: "Limine", removable: false, uki: false },
        custom_commands: [],
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
      }' \
      >"$DIR/user_configuration.json"
    return 0
  fi

  mib=$((1024 * 1024))
  gib=$((mib * 1024))
  disk_size=$(lsblk -bdno SIZE "$disk")
  disk_size=$((disk_size / mib * mib))
  boot_start=$mib
  boot_size=$gib
  root_start=$((boot_start + boot_size))
  root_size=$((disk_size - root_start - mib))

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
collect_disk
until review; do
  keyboard_form
  user_form
  collect_disk
done
write_json
