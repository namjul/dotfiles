# Plan: Niri migration — slice 1

**Branch**: feat/niri-migration-s1
**Status**: Active

**Tier:** comprehensive — multi-aspect desktop migration (aur, dotfiles, systemd, bin scripts), VM reboot verification, UWSM session wiring.

Story source: [`docs/stories/niri-migration.md`](../stories/niri-migration.md). Outcomes fold into `aspects/aur/PLAN.md` after slice 1 lands.

## Goal

After `mise run //aspects/aur:login` and reboot, SDDM autologs into a usable **niri** desktop (Waybar, wofi, swayosd, session systemd units, GNOME portal) while **sway** remains one click away in SDDM with i3status-rust unchanged. No DMS.

## Context & Decisions

| Decision | Rationale |
|---|---|
| Session entry via UWSM + `niri --session` | Matches existing sway pattern; sources `~/.config/uwsm/env` for mise shims |
| Session daemons in systemd, not compositor `spawn-at-startup` | Niri docs + story rule; restart/reload via `systemctl --user` |
| Shipped `mako.service` / `waybar.service` | Pacman units; wire with `add-wants`, do not author replacements |
| Custom units for polkit, udiskie, swayosd | Repo-owned; template: `PartOf`/`After`/`Requisite=graphical-session.target` |
| Waybar on `wayland-wm@niri.service` only | Avoids double bar when picking sway in SDDM |
| Shared daemons on `graphical-session.target` | mako, polkit, udiskie, swayosd run in both sessions; drop duplicate sway `exec` lines |
| Idle: swayidle + niri msg for DPMS | Niri has no idle block yet; niri wiki uses swayidle with `niri msg action power-off-monitors` |
| kanshi / dock profiles deferred | Single laptop `output` in `config.kdl`; use sway session for dock work |
| DMS / matugen / cava deferred to slice 2 | Story explicit out-of-scope |

## Current State

- **`aspects/aur/packages`** — already lists `niri`, `xwayland-satellite`, `dms-shell-niri`, `matugen`, `cava` (slice 2 packages; remove for slice 1). **`waybar` missing.** Portal stack present (`xdg-desktop-portal-gnome`, `-wlr`, `-gtk`).
- **`aspects/aur/login/sddm.sh`** — autologin `Session=sway`; only local sway desktop; no niri desktop file.
- **`aspects/dotfiles/files/.config/niri/config.kdl`** — TODO stub.
- **No `waybar/` config** in repo.
- **`aspects/dotfiles/index.ts`** — does not symlink `.config/niri` or `.config/waybar`; `skipOnDebian` set exists for sway/mako/wofi/etc.
- **`aspects/dotfiles/files/.config/sway/config`** — long-lived daemons still `exec`'d: mako, polkit, udiskie, swayosd, swayidle, kanshi, swaybg.
- **`aspects/systemd/index.ts`** — darkman, gammastep, battery-monitor only; no session units or `add-wants` wiring.
- **`bin/launch-or-focus`** — sway/i3 only (`swaymsg` / `i3-msg`); no niri branch.
- **`bin/launch-upgrade`** — SIGUSR1 → `i3status-rs` only; no `waybarctl reload`.
- **`bin/capture-screenshot`** — grim/slurp/satty; compositor-agnostic (works on niri).
- **`aspects/dotfiles/files/.config/xdg-desktop-portal/sway-portals.conf`** — wlr for screenshot/screencast; no niri-specific portal config.

## Non-Negotiables

- Do not install or require `dms-shell-niri`, `matugen`, `cava` in slice 1.
- Do not use `niri-session` or `uwsm start niri.desktop` (double session management).
- Do not copy niri docs' `add-wants niri.service` verbatim — UWSM uses `wayland-wm@niri.service`.
- Sway SDDM session and i3status-rust bar must remain unchanged.
- Ubuntu/debian paths unchanged (`skipOnDebian` for niri/waybar).
- One commit + VM/hardware check per implementation sub-slice below.

## Technical Approach

### Layer ownership

| Layer | Owner | Files |
|---|---|---|
| Packages | `aspects/aur` | `packages` |
| SDDM / autologin | `aspects/aur/login` | `sddm.sh` |
| Compositor + bar config | `aspects/dotfiles` | `.config/niri/`, `.config/waybar/` |
| Symlinks | `aspects/dotfiles` | `index.ts` |
| Session units + wiring | `aspects/systemd` | `files/.config/systemd/user/`, new `session.ts` or extend `index.ts` |
| Portals | `aspects/dotfiles` | `.config/xdg-desktop-portal/niri-portals.conf` |
| Scripts | `bin/` | `launch-or-focus`, `launch-upgrade` |

### SDDM (`sddm.sh`)

Add local niri desktop alongside existing sway desktop:

```ini
# /usr/local/share/wayland-sessions/niri.desktop
Exec=uwsm start -- niri --session
DesktopNames=niri
Session=niri
```

Change autologin: `Session=niri`. Keep sway desktop `Exec=uwsm start -- sway` unchanged.

### Packages (`packages`)

**Add:** `waybar`

**Remove from slice 1 install line** (comment + note "slice 2"): `dms-shell-niri`, `matugen`, `cava`

**Keep:** `niri`, `xwayland-satellite`, `xdg-desktop-portal-gnome`, `xdg-desktop-portal-gtk`, `qt6-multimedia-ffmpeg`, `alacritty`, sway fallback stack

### `niri/config.kdl` (minimum viable)

Port from sway config where practical; no long-lived daemon spawns.

| Area | Content |
|---|---|
| Input | `de` layout, repeat 200/30 (match sway `input type:keyboard`) |
| Mod | `Mod4` |
| Keybinds | terminal (`launch-terminal`), wofi drun (`$mod+Space`), kill, focus/move, workspaces 1–0, `$mod+Shift+r` reload config |
| Launcher/OSD | wofi `$mod+Space`; Fn volume/brightness → `swayosd-client`; mic → `toggle-mic-mute` |
| Screenshots | Print, `$mod+Shift+s` → `capture-screenshot`; `$mod+Shift+Ctrl+s` → `capture-screenshot fullscreen` |
| Idle | 600s → `swaylock -f`; 900s → `niri msg action power-off-monitors`; before-sleep → `swaylock -f` via systemd `niri-idle.service` |
| Wallpaper | `swaybg` or niri background — reuse existing Bierstadt image path from sway |
| Output | Single laptop layout (no kanshi) |
| Window rules | float `org.namjul.float-win`, `float-win`, `Espanso.SyncTool` (mirror sway `for_window`) |
| Exit | `$mod+Shift+e` — confirm + quit (niri equivalent of swaynag) |

Defer: scratchpad, kanshi mode, full keybind parity, resize mode polish.

### Waybar config

New `aspects/dotfiles/files/.config/waybar/config.jsonc` + `style.css`.

Port **required** modules from [`i3status-rust/config.toml`](../../aspects/dotfiles/files/.config/i3status-rust/config.toml):

| Module | Source behavior |
|---|---|
| clock | time block (`%d %H:%M`) |
| battery | battery block |
| pulseaudio | sound block → click `launch-audio` |
| network | net block → click `launch-wifi` |
| custom/vpn | `omarchy-vpn --waybar` (native JSON; reuse logic from [`bin/omarchy-vpn-i3status`](../../bin/omarchy-vpn-i3status) or call directly) |
| custom/upgrades | `pending-upgrades` → click `launch-upgrade` |
| custom/btop | `󰍛` → click `launch-btop` |

**Optional slice 1:** pomodoro, dropbox (story marks optional).

Style: gruvbox-dark, JetBrainsMono Nerd Font — align with sway bar colors.

### Session systemd units

**Shipped (enable + add-wants only):** `mako.service`, `waybar.service`

**Custom units** in `aspects/systemd/files/.config/systemd/user/`:

```ini
# polkit-gnome-authentication-agent-1.service (name TBD — match niri docs)
Exec=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# udiskie.service
Exec=udiskie --automount --no-notify --no-tray

# swayosd-server.service (if not using pacman-shipped unit)
Exec=swayosd-server
```

All custom units: `PartOf=graphical-session.target`, `After=graphical-session.target`, `Requisite=graphical-session.target`.

**Wiring** (new `session.ts`, called from `mise run //aspects/systemd:enable-services` or dedicated `session` task):

```bash
systemctl --user enable --now mako.service waybar.service  # if not already
systemctl --user add-wants graphical-session.target mako.service
systemctl --user add-wants graphical-session.target polkit-gnome-authentication-agent-1.service
systemctl --user add-wants graphical-session.target udiskie.service
systemctl --user add-wants graphical-session.target swayosd-server.service
systemctl --user add-wants wayland-wm@niri.service waybar.service   # verify instance name
```

**Implement-time gate:** after first niri login, run `systemctl --user list-units 'wayland-wm@*'` and confirm exact target before baking into script.

### Sway config cleanup

Remove `exec` lines superseded by shared systemd units:

- `exec mako`
- `exec /usr/lib/polkit-gnome/...`
- `exec udiskie ...`
- `exec swayosd-server`

**Keep in sway config:** `swayidle`, `kanshi`, `swaybg`, `uwsm finalize`, `nm-applet` (known noop on iwd).

### Portals

Add `aspects/dotfiles/files/.config/xdg-desktop-portal/niri-portals.conf`:

```ini
[preferred]
default=gnome
org.freedesktop.impl.portal.FileChooser=gnome
# keep wlr for screenshot/screencast if grim path still works; verify in VM
```

Symlink strategy: either niri-specific file selected by env, or document that UWSM/niri session sets `XDG_CURRENT_DESKTOP=niri` and portal reads appropriate config — match however sway currently picks `sway-portals.conf` (check UWSM/desktop env at implement time).

### `launch-or-focus`

Add niri branch when `niri` compositor detected (e.g. `pgrep -x niri` or `$NIRI_SOCKET`):

- List windows via `niri msg --json windows` (verify flag at implement time)
- Match on `app_id` / title regex (same jq pattern as sway)
- Focus: `niri msg action focus-window --id=…`
- Launch: `setsid $LAUNCH_COMMAND &` (unchanged)

Preserve existing sway/i3 paths unchanged.

### `launch-upgrade`

After pacman upgrade + existing SIGUSR1:

```bash
command -v waybarctl >/dev/null && waybarctl reload || true
pkill -USR1 -x i3status-rs 2>/dev/null || true
```

### Dotfiles symlinks (`index.ts`)

Add to `files` list:

- `.config/niri`
- `.config/waybar`

Add both to `skipOnDebian` set (Arch-only, like sway).

## Acceptance Criteria

- [ ] After `mise run //aspects/aur:login`, reboot → SDDM autologs niri (`Session=niri`, `Exec=uwsm start -- niri --session`)
- [ ] SDDM session menu still offers sway (`Exec=uwsm start -- sway`); selecting it runs sway with i3status-rust bar unchanged
- [ ] In niri session: `pgrep -a niri`, `systemctl --user is-active waybar mako udiskie polkit-gnome-agent` (exact unit names TBD at implement)
- [ ] Waybar shows clock + battery; VPN block uses `omarchy-vpn --waybar`; pending-upgrades icon when applicable
- [ ] `$mod+space` opens wofi; Fn volume keys trigger swayosd; Print / `$mod+Shift+s` run `capture-screenshot`
- [ ] `pkexec true` shows polkit dialog; USB automount under `/run/media/$USER` with udiskie
- [ ] Idle: unattended 10 min → swaylock; suspend → swaylock before sleep (verify in VM)
- [ ] `pacman -Q niri waybar` succeeds; `dms-shell-niri` not required for slice 1 done
- [ ] Chromium Ctrl+O file picker works (portal-gnome)

## Implementation Slices

Six sub-slices; each leaves repo deployable and is one commit + verification.

### Sub-slice 1: Package set for slice 1

**Value**: Actor (Arch user) gets correct pacman package set — niri stack + waybar, no slice 2 DMS deps.
**Class**: Behavior change.
**Delivery**: Independent PR against trunk.

- Add `waybar` to `aspects/aur/packages`
- Remove/defer `dms-shell-niri`, `matugen`, `cava` (comment with slice 2 reference)

Verification:

```bash
grep -E 'waybar|dms-shell-niri|matugen|cava' aspects/aur/packages
# waybar present; dms/matugen/cava absent or commented
```

### Sub-slice 2: SDDM niri default + sway recovery

**Value**: Reboot lands in niri by default; sway remains selectable in SDDM.
**Class**: Behavior change.
**Delivery**: Independent PR against trunk.

- Extend `aspects/aur/login/sddm.sh`: niri desktop file, `Session=niri` autologin, keep sway desktop

Verification:

```bash
mise run //aspects/aur:sddm
grep Session= /etc/sddm.conf.d/autologin.conf
grep Exec= /usr/local/share/wayland-sessions/niri.desktop /usr/local/share/wayland-sessions/sway.desktop
```

Review: autologin must be `niri`; sway desktop still `uwsm start -- sway`.

### Sub-slice 3: Niri compositor config + dotfiles wiring

**Value**: Niri config exists and is symlinked; compositor can start with keybinds, idle, wallpaper.
**Class**: Behavior change.
**Delivery**: Independent PR against trunk.

- Flesh out `config.kdl` (keybinds, idle, wallpaper, output, window rules)
- Add niri + waybar to `dotfiles/index.ts`

Verification:

```bash
mise run //aspects/dotfiles:files
test -L ~/.config/niri/config.kdl
niri --validate ~/.config/niri/config.kdl   # if available pre-login
```

### Sub-slice 4: Waybar config

**Value**: Top bar on niri shows clock, battery, network, VPN, upgrades with launch clicks.
**Class**: Behavior change.
**Delivery**: Independent PR against trunk.

- Add `config.jsonc` + `style.css` under `.config/waybar/`
- Modules: clock, battery, pulseaudio, network, vpn, upgrades, btop launcher

Verification:

```bash
waybar -c ~/.config/waybar/config.jsonc -l debug &
# manual: modules render; clicks invoke launch-* scripts
killall waybar
```

### Sub-slice 5: Session systemd units + sway dedupe

**Value**: Session daemons run via systemd; no duplicate exec in sway; waybar niri-only.
**Class**: Behavior change.
**Delivery**: Independent PR against trunk.

- Add custom unit files + `session.ts` wiring (`add-wants`)
- Remove duplicate sway `exec` for mako/polkit/udiskie/swayosd
- Extend `aspects/systemd/mise.toml` if new task needed

Verification:

```bash
mise run //aspects/systemd:enable-services --now
systemctl --user is-enabled mako waybar polkit-gnome-authentication-agent-1 udiskie swayosd-server
# after niri login:
systemctl --user is-active mako waybar udiskie polkit-gnome-authentication-agent-1
```

Review: picking sway in SDDM must **not** start waybar; niri must **not** start i3status-rust.

### Sub-slice 6: Portals, scripts, end-to-end acceptance

**Value**: Full slice 1 acceptance criteria pass in VM or hardware.
**Class**: Behavior change.
**Delivery**: Independent PR against trunk.

- `niri-portals.conf`
- `launch-or-focus` niri branch
- `launch-upgrade` dual refresh

Verification (full story acceptance — VM reboot or hardware):

```bash
# After reboot into niri:
pgrep -a niri
systemctl --user is-active waybar mako udiskie polkit-gnome-authentication-agent-1
pacman -Q niri waybar
! pacman -Q dms-shell-niri 2>/dev/null   # must not be installed for slice 1 done

# Interactive:
# $mod+Space → wofi
# Fn volume → swayosd
# Print / $mod+Shift+s → capture-screenshot
# pkexec true → polkit dialog
# USB stick → /run/media/$USER/...
# 10 min idle → swaylock; suspend → swaylock
# chromium Ctrl+O → file picker

# Sway recovery: SDDM → Sway → i3status-rust bar unchanged
```

## Test Strategy

- **Primary:** VM reboot after `mise run //aspects/aur:default` + `mise run //aspects/dotfiles:files` + `mise run //aspects/systemd:default`
- **Automated evidence:** limited — desktop/session behavior; mutation/TDD **N/A** for KDL/waybar/systemd wiring; use story acceptance criteria as manual checklist
- **Regression:** sway session spot-check after each sub-slice touching shared units or packages
- **Characterisation:** before removing sway `exec` lines, capture `pgrep` baseline in sway session

## Documentation Strategy

- Keep spec in `docs/stories/niri-migration.md` until slice 2 done
- After slice 1 merges: add niri section to `aspects/aur/PLAN.md` (session entry, bar choice, systemd wiring)
- Note UWSM compositor unit name in `aspects/systemd/PLAN.md` once verified

## Skills to use

| Skill | When |
|---|---|
| `manage-aspects` | New systemd task, session.ts, dotfiles entries |
| `code` | Implement each sub-slice |
| `reproducible-locally` | VM reboot acceptance gate |
| `sr-eng-review` | After each sub-slice / before PR |
| `expectations` | Document UWSM unit naming gotcha after first login |

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Wrong `wayland-wm@*` target | Discover at first niri login; parameterize in session.ts |
| Waybar starts in sway session | Wire waybar only to niri compositor unit |
| Duplicate daemons during migration | Remove sway exec only after systemd units proven active |
| Portal misconfiguration | Verify Chromium Ctrl+O in niri; keep wlr for screencast if needed |
| `launch-or-focus` API drift | Verify `niri msg` JSON schema against installed niri version |
| Packages already install slice 2 deps | First sub-slice removes dms/matugen/cava before wider rollout |

## Future Work (slice 2+)

- DMS adoption; remove Waybar/wofi/swayosd from niri session
- kanshi → niri `output` blocks
- Scratchpad port
- Full keybind parity
- Fold story outcomes into `aspects/aur/PLAN.md` as primary Arch desktop doc

## Open Questions

1. **Exact UWSM compositor unit** — default assumption `wayland-wm@niri.service`; verify on first login. Fallback: `@niri.desktop`.
2. **Portal config selection** — how niri session picks `niri-portals.conf` vs sway's `sway-portals.conf`. Default: mirror sway pattern (desktop-specific conf file + UWSM env).
3. **swayosd unit** — pacman may ship one; prefer shipped unit if present, else custom. Check `pacman -Ql swayosd | grep systemd` at implement time.
4. **Pomodoro/dropbox in Waybar** — story optional; default **omit** in slice 1 unless you want parity.

## Delivery Shape

Six trunk PRs (one per sub-slice) recommended per `aspects/aur/PLAN.md` discipline; alternatively one PR if you accept a large review surface — story treats slice 1 as one user outcome.

---
*Delete this file when slice 1 is complete. If `plans/` is empty, delete the directory.*
