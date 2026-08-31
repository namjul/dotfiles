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

The custom ISO (`bin/arch-install/mkiso.sh`) runs `keyboard.sh` then `network.sh` on tty1 (gum picks the layout, then the SSID) before the curl below. Layout first so a German keyboard can type the Wi-Fi password. Official monthly ISO does not ship `gum`; `loadkeys de` (or Ethernet / `iwctl`) first.

`network.sh` pings first. No link and no iwd station (a typical VM): it prints `Waiting for Ethernet...` and retries DHCP instead of aborting on Wi-Fi. No link and a station: gum picks the SSID. If it still cannot get a link, it exits and install does not start. `start.sh` prints `Fetching boot.sh...` so a working retry is not a blank TTY.

## Custom ISO

Build from the repo root. On Arch this runs `mkarchiso` on the host. On Ubuntu it re-enters the same script inside a privileged `archlinux` container (`docker` or `podman`).

```bash
# from the repo root (any clone path)
bin/arch-install/mkiso.sh
```

The image is `bin/arch-install/out/*.iso`. Write that file to the USB (same memex note as the official ISO). Rebuild when you next install, not on a calendar.

`--prepare-only` copies `releng`, applies the overlay (`gum`, `keyboard.sh`, `network.sh`, `iso/start.sh`), prints the profile path, and does not run `mkarchiso`.

tty1 auto-starts `keyboard.sh` then `network.sh`, then fetches `boot.sh` to a file and runs it with the TTY as stdin. `/run/arch-install-started` is written only after that succeeds, so a wrong password or Ctrl+C can retry (`arch-install`). Keyboard is stamped at `/run/arch-install-keyboard` so a retry does not ask again. After a successful run, delete the start stamp to start again on the same boot.

## Install (ISO and after reboot)

On the live ISO:

```bash
curl -fsSL https://raw.githubusercontent.com/namjul/dotfiles/master/bin/arch-install/boot.sh | bash
```

ISO: clone → `/root/dotfiles`, run `arch-install.sh` (not bare `archinstall`). After a working ping it rates German HTTPS mirrors (`mirrors.sh` / reflector) and writes those URLs into archinstall `custom_servers`, so pacstrap into `/mnt` does not sit on the two hardcoded geo mirrors. `SKIP_REFLECTOR=1` skips that. In gum: pick the install disk (not the live USB), then **Erase entire disk** or **Leave disk to archinstall TUI**.

Erase: confirm overwrite. LUKS is required. The chosen disk is wiped.

TUI (Windows + Ubuntu): shrink Windows in Disk Management first if you want a hole without deleting Ubuntu. Otherwise delete only **linux**-labeled partitions (typed name confirm; EFI / NTFS / MSR are not offered). Then in the TUI set Disk — existing EFI as `/boot`, the hole as `/`. Disk encryption: pick LUKS, set the password, then apply it to the partition (skip apply and nothing is encrypted). Then Install. Do not pick default layout on the whole NVMe. LUKS + a reused ESP can still fail in archinstall. This path does not write `disk_encryption` for you.

After reboot: unlock LUKS, TTY login as the user you typed. archinstall already cloned this repo over HTTPS (`custom_commands`; default dest `$HOME/.dotfiles`, override `DOTFILES_DIR`) and printed the next command. Start with `boot.sh` so you get the banner, then `install.sh`. After that, later boots go LUKS prompt → SDDM autologin → Sway.

```bash
# default dest; or $DOTFILES_DIR/bin/arch-install/boot.sh
~/.dotfiles/bin/arch-install/boot.sh
```

If that directory is missing (clone failed, or an old ISO), the live-ISO curl still works as a fallback. Branch override on the ISO: `DOTFILES_REF=dev curl -fsSL … | bash` (same vars apply to the clone command). `DOTFILES_DIR` sets the installed-system clone path.

Mount the age stick yourself (`lsblk`, then `sudo mount /dev/sdX1 /mnt/usb`). Restore `~/.config/age/key.txt`, then the store / sops / fnox. The store copy of the identity is not a bootstrap.
