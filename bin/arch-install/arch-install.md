# Reinstall Arch

Official monthly ISO → this wrapper → `install.sh` → age. Two sticks: ISO (whole disk) and age (data). Do not write the ISO onto the age stick.

ISO write: `~/Dropbox/memex/linux.t.arch.iso.md`. Age wrap/restore: `~/Dropbox/memex/pkg.age.usb-identity.md`.

## Boot the ISO

ThinkPad: F12 → **UEFI** USB (not **USB HDD**). Secure Boot off if the menu returns.

## Network (live ISO)

Ethernet: plug in. DHCP is already on.

```bash
ip -br a
ping -c 1 archlinux.org
```

Wi-Fi (`iwctl`, not nmtui):

```bash
iwctl
# device list
# station wlan0 scan
# station wlan0 get-networks
# station wlan0 connect SSID
# exit
ping -c 1 archlinux.org
```

`wlan0` may be `wlan1`.

## Install (ISO and after reboot)

Same command on the live ISO and after reboot. It installs `git` if needed, clones the repo, then picks the step from `/run/archiso` (present only on the official ISO).

```bash
curl -fsSL https://raw.githubusercontent.com/namjul/dotfiles/master/bin/arch-install/boot.sh | bash
```

ISO: clone → `/root/dotfiles`, run `arch-install.sh` (not bare `archinstall`). In gum: pick the install disk (not the live USB), then **Erase entire disk** or **Leave disk to archinstall TUI**.

Erase: confirm overwrite. Ctrl+C toggles LUKS. The chosen disk is wiped.

TUI (Windows + Ubuntu): shrink Windows in Disk Management first if you want a hole without deleting Ubuntu. Otherwise delete only **linux**-labeled partitions (typed name confirm; EFI / NTFS / MSR are not offered). Then in the TUI set Disk — existing EFI as `/boot`, the hole as `/` — before Install. Do not pick default layout on the whole NVMe. LUKS + a reused ESP can still fail in archinstall.

After reboot: unlock LUKS if you set it, TTY login as the user you typed, paste the same command. Clone → `~/.dotfiles`, run `install.sh`.

Branch override: `DOTFILES_REF=dev curl -fsSL … | bash`.

Mount the age stick yourself (`lsblk`, then `sudo mount /dev/sdX1 /mnt/usb`). Restore `~/.config/age/key.txt`, then the store / sops / fnox. The store copy of the identity is not a bootstrap.
