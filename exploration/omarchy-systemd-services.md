# Omarchy systemd services

Reference for adopting omarchy's service setup into a custom dotfiles system. Columns: **Adopt** = relevant for ThinkPad T14 AMD + Hyprland/Wayland | **Ubuntu** = pre-configured by default on Ubuntu desktop.

---

## Display Manager

**Adopt: ✓ | Ubuntu: ✗ (uses GDM)**

Services: `sddm.service`
Source: `install/login/sddm.sh`

What it involves:
- Install and configure SDDM theme
- Copy wayland session desktop file to `/usr/local/share/wayland-sessions/`
- Write `/etc/sddm.conf.d/10-wayland.conf` — `DisplayServer=wayland`, `CompositorCommand` pointing to Hyprland
- Write `/etc/sddm.conf.d/autologin.conf` — autologin user + session
- Patch `/etc/pam.d/sddm` — remove `pam_gnome_keyring.so` lines to prevent keyring conflict with passwordless autologin

---

## Network / WiFi

**Adopt: ✓ | Ubuntu: ✗ (uses NetworkManager + wpa_supplicant)**

Services: `iwd.service`
Source: `install/config/hardware/network.sh`

What it involves:
- Enable `iwd.service`
- Disable and mask `systemd-networkd-wait-online.service` to prevent boot timeout

---

## Firewall

**Adopt: ✓ | Ubuntu: ✓ installed, disabled by default**

Services: `ufw`
Source: `install/first-run/firewall.sh`

What it involves:
- Set default policies: deny incoming, allow outgoing
- Open ports for LocalSend (53317/tcp+udp)
- Add Docker DNS rules if using Docker
- Run `ufw --force enable`

---

## Bluetooth

**Adopt: ✓ | Ubuntu: ✓ enabled**

Services: `bluetooth.service`
Source: `install/config/hardware/bluetooth.sh`

What it involves:
- Enable `bluetooth.service`
- Set `AutoEnable=false` in `/etc/bluetooth/main.conf` to persist last power state across reboots
- Copy wireplumber A2DP autoconnect config to `~/.config/wireplumber/wireplumber.conf.d/`

---

## Power Management

**Adopt: ✓ | Ubuntu: ✓ enabled**

Services: `power-profiles-daemon`
Source: `install/config/powerprofilesctl-rules.sh`

What it involves:
- Only enable if battery is present
- Write udev rule `/etc/udev/rules.d/99-power-profile.rules` to auto-switch profile on AC/battery
- Run `udevadm control --reload` and `udevadm trigger`

---

## Kernel Module Cleanup

**Adopt: ✓ | Ubuntu: ✗**

Services: `linux-modules-cleanup.service`
Source: `install/config/kernel-modules-hook.sh`

What it involves:
- Enable service only — no adjacent config required

---

## Printing

**Adopt: — | Ubuntu: ✓ installed**

Services: `cups.service`, `avahi-daemon.service`, `cups-browsed.service`
Source: `install/config/hardware/printer.sh`

What it involves:
- Enable all three services
- No additional config beyond package installation

---

## Docker

**Adopt: — | Ubuntu: ✗**

Services: `docker.socket`
Source: `install/config/docker.sh`

What it involves:
- Enable `docker.socket` for on-demand activation
- Configure `systemd-resolved` for DNS
- Add ufw rules for Docker container DNS (`ufw-docker install`)
- Write Docker daemon config

---

## Snapshots / Bootloader Sync

**Adopt: — | Ubuntu: ✗**

Services: `limine-snapper-sync.service`
Source: `install/login/limine-snapper.sh`

What it involves:
- Requires BTRFS with Snapper and Limine bootloader
- Syncs bootloader entries with snapshot list

---

## Intel Hardware

**Adopt: ✗ (AMD) | Ubuntu: ✓ thermald on Intel**

Services: `thermald`, `intel_lpmd.service`
Source: `install/config/hardware/intel/thermald.sh`, `install/config/hardware/intel/lpmd.sh`

What it involves:
- Intel CPU thermal throttling and low-power mode management
- Not applicable on AMD

---

## Apple Hardware

**Adopt: ✗ | Ubuntu: ✗**

Services: `t2fanrd.service`, `tiny-dfr.service`, `omarchy-nvme-suspend-fix.service`
Source: `install/config/hardware/apple/`

What it involves:
- T2 chip fan control, Touch Bar driver, NVMe suspend fix
- Only relevant on Apple hardware

---

## Volume / Brightness OSD (User)

**Adopt: — (omarchy-specific) | Ubuntu: ✗**

Services: `swayosd-server.service`
Source: `install/first-run/swayosd.sh`

What it involves:
- Reload user systemd daemon
- Enable and start `swayosd-server.service`

---

## Battery Monitor (User)

**Adopt: — (omarchy-specific) | Ubuntu: ✗**

Services: `omarchy-battery-monitor.timer`
Source: `install/first-run/battery-monitor.sh`

What it involves:
- Enable user timer that fires low-battery alerts

---

## Monitor Recovery (User)

**Adopt: — (omarchy-specific) | Ubuntu: ✗**

Services: `omarchy-recover-internal-monitor.service`
Source: `install/first-run/recover-internal-monitor.sh`

What it involves:
- Enable user service that recovers internal display after external monitor disconnect

---

## AI Assistant Daemon (User)

**Adopt: ✗ | Ubuntu: ✗**

Services: `elephant.service`
Source: `install/first-run/elephant.sh`

What it involves:
- Omarchy-specific background AI daemon
- Start user service
