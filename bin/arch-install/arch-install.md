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

The custom ISO (`bin/arch-install/mkiso.sh`) runs `network.sh` on tty1 (gum picks the SSID) before the curl below. Official monthly ISO does not ship `gum`; use Ethernet or `iwctl` first. If `network.sh` cannot get a link, it exits and install does not start.

## Custom ISO

Build from the repo root. On Arch this runs `mkarchiso` on the host. On Ubuntu it re-enters the same script inside a privileged `archlinux` container (`docker` or `podman`).

```bash
cd ~/.dotfiles && bin/arch-install/mkiso.sh
```

The image is `bin/arch-install/out/*.iso`. Write that file to the USB (same memex note as the official ISO). Rebuild when you next install, not on a calendar.

`--prepare-only` copies `releng`, applies the overlay (`gum`, `network.sh`, `iso/start.sh`), prints the profile path, and does not run `mkarchiso`.

tty1 auto-starts `network.sh` then the curl one-liner. `/run/arch-install-started` prevents a respawned getty from curling again; delete that file to retry on the same boot.

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
