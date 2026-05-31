# aspects/systemd plan

Expand the systemd aspect to own all system service concerns, each as a separate script + mise task.

## Target structure

```
aspects/systemd/
  index.ts          — user services: ssh-agent, darkman, redshift, swayosd, battery-monitor, recover-monitor
  network           — iwd, mask systemd-networkd-wait-online
  bluetooth         — bluetooth.service + wireplumber A2DP config + /etc/bluetooth/main.conf
  power             — power-profiles-daemon + udev rule for AC/battery switching
  display           — sddm + wayland session desktop + autologin + PAM patch
  kernel            — linux-modules-cleanup
  mise.toml         — task per concern + updated default
  files/            — existing user service files
```

## Tasks to add to mise.toml

```toml
[tasks."network"]
[tasks."bluetooth"]
[tasks."power"]
[tasks."display"]
[tasks."kernel"]
```

Update `[tasks.default]` to depend on all concerns.

## Per-concern detail

Each script guards with `when(...)` at the top and exits 0 if not applicable.

### network
Omarchy source: `install/config/hardware/network.sh`

Without this, boot hangs for ~90 seconds on a fresh Arch install — `systemd-networkd-wait-online` waits for a network connection that iwd manages independently and never signals back. Configures iwd as the WiFi daemon and masks the waiting service to eliminate the boot delay.
- Platform: `when("arch")` — Ubuntu uses NetworkManager + wpa_supplicant; enabling iwd there would conflict with the existing network stack
- `sudo systemctl enable --now iwd.service`
- `sudo systemctl disable systemd-networkd-wait-online.service` — stops the service from being pulled in by other units
- `sudo systemctl mask systemd-networkd-wait-online.service` — prevents it from being started at all, even as a dependency; stronger than disable alone

### bluetooth
Omarchy source: `install/config/hardware/bluetooth.sh`

Without the WirePlumber config, Bluetooth headphones connect but only on the HFP/HSP profile — low-quality mono phone audio instead of stereo. Without `AutoEnable=false` in `/etc/bluetooth/main.conf`, the Bluetooth daemon ignores whatever power state the user left it in and turns Bluetooth on at every boot regardless — the default is `AutoEnable=true`. Setting it to `false` makes the daemon restore the last known state instead.
- Platform: `when("arch")` — modifies `/etc/bluetooth/main.conf` and drops wireplumber config; could override Ubuntu's bluetooth defaults
- `sudo systemctl enable --now bluetooth.service`
- Set `AutoEnable=false` in `/etc/bluetooth/main.conf`
- Copy wireplumber A2DP autoconnect config to `~/.config/wireplumber/wireplumber.conf.d/`

### power
Omarchy source: `install/config/powerprofilesctl-rules.sh`

Without this, the system stays on the same power profile regardless of whether it is on AC or battery — draining the battery fast on performance mode, or throttling on AC when on power-saver. Installs a udev rule that switches profiles automatically on plug/unplug.
- Platform: `when("arch")` — writes a udev rule for auto power profile switching; could interfere with GNOME's power management on Ubuntu
- Only run if battery present (`/sys/class/power_supply/` has a battery entry)
- `sudo systemctl enable --now power-profiles-daemon`
- Write udev rule `/etc/udev/rules.d/99-power-profile.rules`
- `sudo udevadm control --reload && sudo udevadm trigger`

### display
Omarchy source: `install/login/sddm.sh`

Without the PAM patch, GNOME keyring creates an encrypted keyring on first login that prompts for a password on every boot — even with autologin configured — blocking access to WiFi credentials and SSH keys. The autologin config is omarchy-specific; omit it if you want a login screen.
- Platform: `when("arch")` — Ubuntu ships GDM; enabling SDDM there would create two competing display managers
- Configure SDDM for wayland: `/etc/sddm.conf.d/10-wayland.conf`
- Configure autologin: `/etc/sddm.conf.d/autologin.conf`
- Patch `/etc/pam.d/sddm`: remove `-auth` and `-password` pam_gnome_keyring lines only — keep `-session`. The session line starts gnome-keyring-daemon at login and sets `SSH_AUTH_SOCK` automatically. Removing it would require manually propagating `SSH_AUTH_SOCK` via the UWSM env file.
- `sudo systemctl enable sddm.service`

### kernel
Omarchy source: `install/config/kernel-modules-hook.sh`

Without this, old kernel module directories accumulate in `/usr/lib/modules/` after every kernel upgrade, wasting disk space and potentially causing `modprobe` to pick up stale modules from previous kernels.
- Platform: `when("arch")` — `linux-modules-cleanup.service` is a pacman-specific unit, does not exist on Ubuntu

### index.ts — user services to add

Omarchy sources: `install/first-run/swayosd.sh`, `install/first-run/battery-monitor.sh`, `install/first-run/recover-internal-monitor.sh`

Extend the existing user service block alongside ssh-agent/darkman/redshift:
- `swayosd-server.service` — volume/brightness OSD for Hyprland; requires `swayosd` package
- `omarchy-battery-monitor.timer` — fires low-battery alerts on a timer; requires the service unit files in `files/`
- `omarchy-recover-internal-monitor.service` — recovers internal display after external monitor disconnect; requires the service unit file in `files/`

## Package prerequisites

Packages that must be present before each concern runs. Add missing ones to `aspects/aur/packages` first.

| Concern | Package | Repo | In `aur/packages` |
|---|---|---|---|
| kernel | `linux-modules-cleanup` | AUR | No — blocked until paru is available |
| power | `power-profiles-daemon` | official | No — add with pacman |
| bluetooth | `bluez`, `bluez-utils`, `wireplumber` | official | Yes |
| network | `iwd` | official | Yes |
| user services | `swayosd` | AUR | No — blocked until paru is available |
| display | `sddm` | official | No — add with pacman |

## Implementation sequence

Ordered low-risk → high-risk. Each concern is implemented, committed, and tested before moving to the next.

| # | Concern | VM testable | Test command |
|---|---|---|---|
| 1 | kernel | Yes | `systemctl is-enabled linux-modules-cleanup.service` |
| 2 | power | Guard path only (no battery in VM) | Script should log "no battery, skipping" and exit 0 |
| 3 | bluetooth | Partial (no hardware) | `systemctl is-enabled bluetooth.service`; `grep AutoEnable /etc/bluetooth/main.conf`; `ls ~/.config/wireplumber/wireplumber.conf.d/` |
| 4 | network | Verify state, not connectivity | `systemctl is-enabled iwd.service`; `systemctl is-masked systemd-networkd-wait-online.service` |
| 5 | user services | Enable only (no compositor) | `systemctl --user is-enabled swayosd-server.service omarchy-battery-monitor.timer omarchy-recover-internal-monitor.service` |
| 6 | display | Files + enable only | `cat /etc/sddm.conf.d/10-wayland.conf`; `grep pam_gnome_keyring /etc/pam.d/sddm` (empty); `systemctl is-enabled sddm.service` |

Network and display need real hardware for full validation — the VM lacks iwd-managed WiFi and a graphical login flow.

## Notes

- All system service enablement needs sudo
