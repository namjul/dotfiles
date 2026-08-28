# Arch desktop bootstrap (`aspects/aur`)

**Tier:** comprehensive — the aspect is the Arch session contract (packages, login, remaining desktop gaps). Multi-file, VM-tested, overlaps `dotfiles` and `systemd`.

Hyprland was tried and dropped (2026-07-05). Sway is the compositor. The old step tables lived in `PLAN.hyprland.md` / `PLAN.sway.md`; this file replaces both.

## Goal

After official Arch ISO + `bin/arch-install/arch-install.sh` + `./install.sh`, `mise run //aspects/aur:default` leaves a usable Sway desktop: SDDM login, keyring, portals, launcher, screenshots, clipboard, volume OSD, idle lock, and removable-media automount.

Ubuntu stays X11 + `i3-wm` via `aspects/nala`. Do not remove the i3 fallback on Arch.

## Context & Decisions

`aur` is already that aspect. `install.sh` runs `//aspects/aur:default`. Do not add `aspects/desktop` or rename `aur`.

Session config lives in `aspects/dotfiles/files/.config/sway/config` (Arch-only; `skipOnDebian`). i3 config is Ubuntu-only (`skipOnArch`). Packages and login scripts stay in `aspects/aur`.

Install path is official Arch ISO + archinstall, then this repo. Not Omarchy quattro / `omarchy-iso`. See `exploration/arch-install.md`.

Omarchy (`~/code/ghq/github.com/basecamp/omarchy/`) is a reference for login, polkit, and removable media — not a compositor or ISO contract.

## Current State

Done in `aspects/aur/packages` and `aspects/aur/login/`, VM-tested unless noted:

| Concern | Where |
|---|---|
| Fonts, man | `noto-fonts`, `noto-fonts-emoji`, `man-db` |
| Keyring | `gnome-keyring`, `libsecret`; `login/default-keyring.sh` (passwordless Default_keyring; socket activation; PAM session line keeps `SSH_AUTH_SOCK`) |
| Login | `sddm`; `login/sddm.sh` (drop PAM `-auth`/`-password` gnome-keyring; `systemctl enable sddm`; reboot verified on hardware) |
| Compositor | `sway`, `swaybg`, `mako`, `libnotify`, `i3status-rust`, `alacritty` — Hyprland/uwsm/portal-hyprland removed |
| Portals / Qt | `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gtk`, `qt5-wayland`, `qt6-wayland` |
| Polkit | `polkit-gnome` + `exec` in sway config; `lxsession` kept for i3 fallback |
| Launcher | `wofi` + `$mod+space`; spec: `SPEC.sway-step-9-wofi.md` (`78ef905f`) |
| Screenshots / clipboard | `grim`, `slurp`, `satty`, `wl-clipboard`; `bin/capture-screenshot` (`942d10b5`) |
| Volume OSD | `pamixer`, `swayosd` (`f747f33f`) |
| Idle lock | `swayidle`, `swaylock` (`c80d3b65`) |
| Dual-stack | `i3-wm` + X11 tools stay installed on Arch as fallback |

`mise.toml` default: `packages` + `login` + `firewall`. Firmware is a separate task.

Sway recovery if SDDM loops: `Ctrl+Alt+F2` → `sudo systemctl disable --now sddm` → start sway from TTY (`WLR_RENDERER=pixman sway` in VM).

## Non-Negotiables

- Arch-only for new desktop packages and login scripts. Ubuntu `nala` + i3 unchanged.
- Keep `i3-wm` on Arch.
- One step committed and VM-tested before the next.
- Password-store clone/decrypt stays manual (`exploration/encryption.md`). No mise task for that.
- Do not reintroduce Hyprland, uwsm, or the omarchy-iso package-list contract.
- Power-profile *enablement* belongs in `aspects/systemd` (`aspects/systemd/PLAN.md`). `aur` only adds the package.

Out of first pass: docker, CUPS, waybar, kanshi (until docking), gromit-mpx, paru/AUR-only packages, NetworkManager (`nm-applet` in sway config is an i3 leftover; Arch uses `iwd`).

## Technical Approach

`aur` interface: `mise run //aspects/aur:default` on Arch after preflight. Implementation is bash tasks + fig-less login scripts (same pattern as today).

| Layer | Owner |
|---|---|
| pacman, mirrors, desktop packages | `aspects/aur/packages` |
| keyring + SDDM PAM/enable | `aspects/aur/login/` |
| sway binds, `exec` lines | `aspects/dotfiles/files/.config/sway/config` |
| user systemd units | `aspects/systemd` |
| $HOME links | `aspects/dotfiles` |

Removable media (Ubuntu vs this repo vs Omarchy): see slice 1. Ubuntu automounts because `nala` installs `nautilus-dropbox`, which pulls Nautilus + gvfs + udisks2. This repo's Arch package list has none of those. Sway already binds `$mod+Shift+f` to `gtk-launch org.gnome.Nautilus`. Omarchy installs `udiskie`, `nautilus`, `gvfs-mtp`/`gvfs-nfs`/`gvfs-smb` and runs `udiskie --automount --no-notify --no-tray` from Hyprland autostart (`default/hypr/autostart.lua`, migration `1781793381.sh`).

Keyring facts (from the old Hyprland writeup, still true):

- Passwordless `~/.local/share/keyrings/Default_keyring.keyring` + `default` avoids the first-secret create-keyring dialog.
- Keep PAM `-session` pam_gnome_keyring; drop `-auth` and `-password` so SDDM does not create an encrypted login keyring that fights the passwordless default.

## System Impact

- New packages: `udiskie`, `nautilus`, `gvfs`, `gvfs-mtp`, `exfatprogs`, `ntfs-3g`, later `power-profiles-daemon`.
- `udiskie` needs the existing polkit agent (already `exec`'d). Without it, mounts that need auth hang.
- `passmenu` change is Wayland-only; keep the rofi path for X11.
- systemd `display` concern in `aspects/systemd/PLAN.md` is already done here (`login/sddm.sh`). Do not implement SDDM a second time.

## Implementation Slices

### Slice 1: Removable media automount

Plug a USB stick → it mounts under `/run/media/$USER/<label>` without opening a file manager. Same expectation as Ubuntu; same mechanism as Omarchy (`udiskie`).

- Add to `aspects/aur/packages`: `udiskie`, `nautilus`, `gvfs`, `gvfs-mtp`, `exfatprogs`, `ntfs-3g`.
- `exec udiskie --automount --no-notify --no-tray` in `aspects/dotfiles/files/.config/sway/config` (next to polkit-gnome).
- Do not add a tray icon. Do not use udev/`fstab` automount.

Verification:

- `pacman -Q udiskie nautilus gvfs gvfs-mtp exfatprogs ntfs-3g`
- `pgrep -a udiskie` inside a Sway session
- Plug a USB (exFAT or ext4) → `findmnt /run/media/$USER` shows the mount; `$mod+Shift+f` opens Nautilus on it
- `pkexec true` still shows the polkit dialog (agent still running)

Review:

- No NetworkManager or `gvfs-smb`/`gvfs-nfs` unless a later slice asks for them.
- Ubuntu i3 config unchanged.

### Slice 2: `passmenu` on Wayland

Needs slice-independent store work first: clone/decrypt `~/.password-store` per `exploration/encryption.md`. Then:

- Branch `bin/passmenu` on `WAYLAND_DISPLAY`: `wofi --dmenu --prompt pass: -i -M fuzzy -L 15` vs existing rofi.
- Add `passmenu.desktop` so wofi drun can launch it.
- Keep the X11/rofi path.

Verification:

- `passmenu` → pick an entry → `wl-paste` has the secret
- On X11/i3, `passmenu` still uses rofi

Review:

- Do not change store crypto or `PASSWORD_STORE_DIR` in this slice.

### Slice 3: Power profiles package

- Add `power-profiles-daemon` to `aspects/aur/packages`.
- Enablement + udev AC/battery rule: `aspects/systemd` (`PLAN.md` power concern). Skip if no battery (`/sys/class/power_supply/`).

Verification:

- `pacman -Q power-profiles-daemon`
- VM: systemd power script exits 0 with a skip log
- Hardware: `powerprofilesctl get` after plug/unplug

### Slice 4: kanshi (when docking)

Not needed for single-monitor VM. When multi-monitor matters:

- Install `kanshi`; `exec kanshi` from sway config.
- Port named profiles from the old autorandr binds in i3/sway config.

Verification:

- Dock/undock changes outputs without manual `swaymsg output`

## Test Strategy

Before marking a slice done:

1. If the slice has an Omarchy counterpart, diff behavior (not formatting) against `~/code/ghq/github.com/basecamp/omarchy/`.
2. Run the slice verification in a clean Arch VM (or hardware for battery/USB/SDDM reboot).

Portal note (already proven): `xdg-desktop-portal` may be `inactive (dead)` until used. File picker (`chromium` Ctrl+O) is the proof for gtk portal. `xdg-desktop-portal-wlr` is for screenshot/screencast, already covered by grim/satty.

## Documentation Strategy

- This file is the only aur desktop plan. Update links that pointed at `PLAN.sway.md` / `PLAN.hyprland.md`.
- After slice 1: one paragraph in `aspects/aur/docs.md` (or a short `CONTEXT.md`) stating the automount command and mount path.
- `AGENTS.md` aspect line for `aur` should say it bootstraps the Arch desktop, not only pacman preflight.

## Skills to use

- `manage-aspects` — any new aur task or script
- `code` — turning a slice into packages + sway `exec` / `passmenu`
- `sr-eng-review` — after each slice commit
- `research` — Omarchy diff before marking a slice done

## Risks & Mitigations

- USB in a VM needs a passed-through stick or a virtio disk treated as removable — test automount on hardware if the VM cannot see a real USB.
- Nautilus pulls a large GTK stack. Accept that; the sway bind already assumes it.
- `udiskie` without polkit-gnome will prompt in the wrong place or fail. Keep the existing `exec` of `polkit-gnome-authentication-agent-1`.
- `nm-applet` in sway config will fail on Arch (`iwd`, no NetworkManager). Leave it until a network-applet slice; do not install NetworkManager to silence the error.

## Future Work

- docker: Omarchy `install/config/docker.sh` — `docker` + `docker-compose`, `docker.socket`, user in `docker` group
- printing: Omarchy `install/config/hardware/printer.sh` — `cups`, `avahi`, `cups-pdf`
- waybar (optional; sway `bar {}` + i3status-rust is enough)
- `gvfs-smb` / `gvfs-nfs` if those shares become daily
- paru + commented AUR lines in `packages`

## Open Questions

- Store CLI (`gopass` vs `passage`) — already parked in `exploration/encryption.md`. Default: keep `gopass`/`pass` until that doc decides.
- Whether to drop the `nm-applet` exec on Arch-only sway config in a later cleanup. Default: yes, in a dedicated network-tray slice, not slice 1.

## Lookup

- Sway i3 compatibility: https://github.com/swaywm/sway/wiki/i3
- Omarchy (login / remount reference): `~/code/ghq/github.com/basecamp/omarchy/`
- i3 source: `aspects/dotfiles/files/.config/i3/config`
- Install path: `exploration/arch-install.md`
- Secrets: `exploration/encryption.md`
- systemd services: `aspects/systemd/PLAN.md`
