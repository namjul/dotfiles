# Specification map: niri migration

story: Switch Arch default desktop from sway to niri via UWSM; slice 1 boots niri with Waybar + existing modules (no DMS); slice 2 adopts DMS; sway soft-deprecated (2026-09)

> **2026-09 update:** Sway removed from packages, SDDM, and dotfiles symlinks. Config kept under `aspects/dotfiles/files/.config/sway/` for reference only. Recovery: TTY `uwsm start -- niri --session`.

rules:
  - rule: Story artifact lives under docs/stories
    examples:
      - This file is the home for rules, examples, parked questions, and acceptance criteria until the map stabilises; outcomes fold back into `aspects/aur/PLAN.md` later.

  - rule: Niri session enters through UWSM with the compositor session flag, not niri-session
    examples:
      - SDDM local desktop uses `Exec=uwsm start -- niri --session` and `Session=niri` (not `Exec=niri-session`, not `uwsm start niri.desktop` — avoids double session management).
      - UWSM sources `~/.config/uwsm/env` before niri starts, so mise shims and `~/.local/bin` stay on PATH for all session children (same contract as sway today).
      - Under UWSM, package `niri.service` does not run — compositor is `wayland-wm@niri.service`. Do not copy niri docs' `add-wants niri.service …` verbatim; use UWSM-equivalent anchors (see session-units rule).

  - rule: Session daemons are systemd user services, not compositor spawn-at-startup
    examples:
      - Niri docs recommend service files over `spawn-at-startup` for mako, waybar, etc. ([Example systemd Setup](https://niri-wm.github.io/niri/Example-systemd-Setup.html)) — monitor, restart, reload via `systemctl --user`.
      - **Shipped units:** `mako.service` and `waybar.service` come from pacman — enable/wire them; do not author custom mako/waybar units unless overriding.
      - **Custom units** (repo-owned): `polkit-gnome-agent.service`, `udiskie.service`, optionally `swayosd-server.service` — template from niri docs: `PartOf=graphical-session.target`, `After=graphical-session.target`, `Requisite=graphical-session.target`.
      - **Wiring under UWSM (slice 1):**
        - **Niri-only:** `waybar.service` → `systemctl --user add-wants wayland-wm@niri.service waybar.service` (avoids Waybar + sway i3 bar when picking sway in SDDM).
        - **Both sessions:** `mako.service`, polkit, udiskie, swayosd → `add-wants graphical-session.target …` (remove duplicate `exec` lines from sway config).
        - Prove exact UWSM compositor instance id at implement time (`wayland-wm@niri.service` vs `@niri.desktop`); adjust add-wants target if needed.
      - Niri-native path would use `add-wants niri.service mako waybar` — not our path while UWSM wraps the compositor.

  - rule: SDDM autologs into niri (sway recovery session removed 2026-09)
    examples:
      - `/etc/sddm.conf.d/autologin.conf` sets `Session=niri` (not `sway`).
      - Local `/usr/local/share/wayland-sessions/niri.desktop` uses `Exec=uwsm start -- niri --session`, `DesktopNames=niri`.
      - ~~Sway SDDM session~~ — removed; `aspects/dotfiles/files/.config/sway/` kept in repo unlinked for reference.

  - rule: Slice 1 — niri daily driver without DMS; Waybar replaces the sway bar
    examples:
      - Packages for slice 1: `niri`, `xwayland-satellite`, `xdg-desktop-portal-gnome`, `xdg-desktop-portal-gtk`, `alacritty`, `qt6-multimedia-ffmpeg`, `waybar`. Defer `dms-shell-niri`, `matugen`, `cava` to slice 2.
      - `i3status-rust` does not run on niri (no sway bar protocol). Top bar is **Waybar** via a systemd user unit on `graphical-session.target`, config under `~/.config/waybar/` (port battery, clock, sound, net, VPN, pending-upgrades, launch clicks from `i3status-rust` behavior; pomodoro/dropbox optional).
      - Launcher/OSD on niri slice 1: keep **wofi** (`$mod+space`) and **swayosd** (Fn keys) — same role as sway until DMS replaces them in slice 2.
      - Session daemons move out of compositor config into systemd: wire **shipped** `mako.service` / `waybar.service`; add **custom** units for polkit, udiskie, swayosd (see session-units rule for niri-only vs shared wiring).
      - `~/.config/niri/config.kdl`: keybinds, wallpaper, idle/lock, screenshots, output layout — not long-lived `exec` daemons (those are systemd).
      - Dock/output profiles: kanshi via systemd on niri (`kanshi.service` on `wayland-wm@niri.service`); `$mod+x` profile picker in sway, `$mod+x` → `kanshi-menu` (wofi) on niri. Shared config: `~/.config/kanshi/config`.
      - Idle/lock on niri slice 1: **swayidle systemd unit** with `niri msg action power-off-monitors` for DPMS (niri wiki Example-systemd-Setup; swayidle is fine when not using swaymsg). Match sway timeouts: lock at 600s, DPMS off at 900s, before-sleep lock.

  - rule: After upgrade, refresh Waybar (i3status-rs removed with sway)
    examples:
      - `bin/launch-upgrade` runs `waybarctl reload` when waybarctl exists.

  - rule: Slice 2 — adopt DMS; retire duplicate chrome on niri session
    examples:
      - Add `dms-shell-niri`, `matugen`, `cava`; run `dms setup`; `add-wants graphical-session.target dms`.
      - Remove Waybar unit, wofi launcher bind, and swayosd from niri session once DMS covers bar, spotlight, and control center.

questions:
  - Where is the story artifact? → `docs/stories/niri-migration.md` (this file)
  - Session entry? → UWSM + `niri --session`, units on `graphical-session.target`
  - Sway fallback in SDDM? → **removed** (2026-09 soft deprecation); recovery via TTY niri
  - DMS in slice 1? → **no** — slice 2
  - Bar on niri slice 1? → **Waybar**
  - Launcher/OSD on niri slice 1? → **wofi + swayosd** (DMS replaces in slice 2)
  - Dock/output profiles (kanshi)? → **kanshi systemd unit on niri** + `kanshi-menu` on `$mod+x`; sway keeps `exec kanshi` + modal binds
  - Idle/lock on niri? → **swayidle + niri msg** (systemd `niri-idle.service`; not swaymsg)
  - Session units: shared vs niri-only? → **mako/polkit/udiskie/swayosd on `graphical-session.target`** (drop sway `exec` dupes); **waybar on `wayland-wm@niri.service`** (niri-only); use **shipped** mako/waybar units per niri docs
  - `launch-upgrade` refresh after upgrade? → `waybarctl reload`

acceptance criteria:
  - After `mise run //aspects/aur:login`, reboot → SDDM autologs niri (`Session=niri`, `Exec=uwsm start -- niri --session`)
  - ~~SDDM sway session~~ — removed 2026-09
  - In niri session: `pgrep -a niri`, `systemctl --user is-active waybar mako udiskie polkit-gnome-agent` (exact unit names TBD at implement)
  - Waybar shows clock + battery; VPN block uses `omarchy-vpn --waybar`; pending-upgrades icon when applicable
  - `$mod+space` opens wofi; Fn volume keys trigger swayosd; Print / `$mod+Shift+s` run `capture-screenshot`
  - `pkexec true` shows polkit dialog; USB automount under `/run/media/$USER` with udiskie
  - Idle: unattended 10 min → swaylock; suspend → swaylock before sleep (verify in VM)
  - `pacman -Q niri waybar` succeeds; `dms-shell-niri` not required for slice 1 done
  - Chromium Ctrl+O file picker works (portal-gnome)

candidate terms:
  - slice 1 — niri boots via UWSM; Waybar + wofi + swayosd; session systemd units; no DMS
  - slice 2 — DMS adoption; drop Waybar/wofi/swayosd from niri session
  - niri.service — package unit used by `niri-session` path only; not the wiring anchor under UWSM
  - dms — Dank Material Shell; slice 2 only
  - session file — systemd user unit; custom ones for polkit/udiskie/swayosd; mako/waybar use pacman-shipped units
  - niri-only wiring — `add-wants wayland-wm@niri.service` for services that must not run in sway session (waybar)
  - uwsm session — UWSM wraps compositor, sources `uwsm/env`, activates `graphical-session.target`
  - sway fallback — **deprecated 2026-09**; config in repo for reference only

## Story split

### Parent

After slice 1, Arch autologs into a usable niri desktop (Waybar, wofi, swayosd, session units, portals). Sway soft-deprecated 2026-09. After slice 2, DMS replaces that chrome stack on niri.

### Slice 1 (current scope)

Niri boots as default session with Waybar and existing modules; no DMS.

**In scope:** `sddm.sh` niri + sway desktops, `niri/config.kdl`, `waybar/`, session units in `aspects/systemd`, `dotfiles/index.ts` (`.config/niri`, `.config/waybar`), portals conf for niri, `launch-or-focus` niri branch, `launch-upgrade` dual bar refresh, packages (niri stack + waybar, not dms-shell-niri).

**Out of scope slice 1:** DMS, matugen, cava, kanshi/dock output profiles, scratchpad port, full keybind parity with sway.

**Verify:** acceptance criteria above in VM or hardware reboot.

### Slice 2 (later)

Adopt DMS; remove duplicate bar/launcher/OSD from niri session.
