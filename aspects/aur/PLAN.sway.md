# aspects/aur plan — Sway (active)

**Target:** Arch + Wayland + **Sway** (i3-compatible WM). Ubuntu keeps X11 + `i3-wm` unchanged.

**Archived Hyprland plan:** [PLAN.hyprland.md](PLAN.hyprland.md)

## Wayland desktop implementation sequence

Arch-only additions. Each step is implemented, committed, and tested before moving to the next. X11 packages (`i3-wm`, `feh`, `xclip`, `xsel`, `wmctrl`) stay for Ubuntu.

**Before marking a step complete:**

1. **Reference diff** — for boot/login steps, compare omarchy `install/login/` where applicable. For Sway-specific steps, use [Sway i3 compatibility](https://github.com/swaywm/sway/wiki/i3) and port from `aspects/dotfiles/files/.config/i3/config` → `aspects/dotfiles/files/.config/sway/config`. Report behavioral gaps only.
2. **VM test** — run verification commands in a clean Arch VM. Mark done only after tests pass.

Sequence: sddm → PAM → sway → runtime components. SDDM installed early (step 3); `systemctl enable sddm` deferred to step 16 so steps 4–15 test from TTY.

| # | What | Concern / Purpose | Test in VM | Notes |
|---|---|---|---|---|
| ~~1~~ | ~~`noto-fonts`, `noto-fonts-emoji`, `man-db`~~ | ~~Typography~~ | ~~`fc-list \| grep Noto`~~ | ~~Shared with hyprland plan~~ |
| ~~2~~ | ~~`gnome-keyring`, `libsecret` + `login/default-keyring.sh`~~ | ~~Credentials~~ | ~~`gnome-keyring-daemon --version`~~ | ~~Done~~ |
| ~~3~~ | ~~`sddm` + `login/sddm.sh`~~ | ~~Login manager (PAM + enable)~~ | ~~`pacman -Q sddm`; PAM session line; `systemctl is-enabled sddm` → enabled~~ | ~~In `login` task; `enable` only (no `--now`) — omarchy pattern; reboot for greeter (step 16)~~ |
| ~~4~~ | ~~`sway` (+ swap compositor packages)~~ | ~~Wayland compositor — i3-compatible; port `i3/config` → `sway/config`~~ | ~~`sway --version`; `WLR_RENDERER=pixman sway` from TTY~~ | ~~**Replace** `hyprland`/`uwsm`/`portal-hyprland` in `packages` with `sway`; remove `aspects/dotfiles/.../hypr/` or leave unused~~ |
| ~~5~~ | ~~`mako`~~ | ~~Notifications~~ | ~~`notify-send test` in sway~~ | ~~`dunst` stays on Ubuntu~~ |
| ~~6~~ | ~~`xdg-desktop-portal-wlr`, `xdg-desktop-portal-gtk`, `qt5-wayland`, `qt6-wayland`~~ | ~~Wayland portals + Qt Wayland~~ | ~~`pacman -Q …`; Chromium `Ctrl+O` file dialog in sway~~ | ~~Done — portal-wlr activation deferred to step 11; see Step 6 done rule~~ |
| 7 | password store import | Password store from GitHub — decrypt secrets | store `ls`; `fnox exec -- env \| rg GITHUB_TOKEN` | `~/.password-store`; SSH via `aspects/ssh`; manual: [encryption.md](../../exploration/encryption.md) |
| ~~8~~ | ~~`polkit-gnome`~~ | ~~Auth agent for privileged actions~~ | ~~`pkexec true` → polkit dialog in sway; auth succeeds~~ | ~~`exec` in `sway/config`; replaces `lxpolkit`; package in `aspects/aur/packages`~~ |
| ~~9~~ | ~~sway `bar {}` + `i3status-rust`~~ | ~~Status bar (status quo)~~ | ~~Bar shows workspaces/status in sway~~ | ~~Done as shipped in step 4; **waybar deferred** (optional later, not blocking)~~ |
| ~~10~~ | ~~`wofi`~~ | ~~App launcher~~ | ~~Launch via `$mod+space` in sway~~ | ~~Done — `78ef905f`; replaces X11 `rofi` bind; spec: [SPEC.sway-step-9-wofi.md](SPEC.sway-step-9-wofi.md)~~ |
| ~~11~~ | ~~`grim`, `slurp`, `satty`~~ | ~~Screenshots~~ | ~~`capture-screenshot`; region + fullscreen in sway~~ | ~~Done — `942d10b5`; `bin/capture-screenshot`; i3 keeps flameshot~~ |
| ~~12~~ | ~~`wl-clipboard`~~ | ~~Wayland clipboard~~ | ~~`wl-copy` / `wl-paste`~~ | ~~Done — `942d10b5` (installed with step 11); prerequisite for step 13~~ |
| 13 | `passmenu` → wofi dmenu | password picker on Wayland | `passmenu` → wofi → `wl-paste`; wofi drun via `.desktop` | Needs 7 + 10 + 12. Do: branch `bin/passmenu` on `WAYLAND_DISPLAY` (`wofi --dmenu --prompt pass: -i -M fuzzy -L 15` vs rofi); add `passmenu.desktop`; keep X11/rofi path. |
| ~~14~~ | ~~`pamixer`, `swayosd`~~ | ~~Volume OSD~~ | ~~Volume keys show OSD~~ | ~~Done — `f747f33f`; mic mute deferred (VM key forwarding); i3 keeps pactl~~ |
| ~~15~~ | ~~`swayidle`, `swaylock`~~ | ~~Idle lock~~ | ~~`swaylock` manually; idle blank~~ | ~~Done — `c80d3b65`; replaces `xss-lock` + `i3lock`~~ |
| ~~16~~ | ~~Reboot + sway session via SDDM~~ | ~~Full login flow~~ | ~~`systemctl is-enabled sddm`; reboot → SDDM → pick Sway → `SSH_AUTH_SOCK` set~~ | ~~Done — reboot verified; `login/sddm.sh` in login task~~ |
| 17 | `power-profiles-daemon` + systemd concern | Power profiles | Skip in VM (no battery) | Real hardware |

### Step 16 — recovery

After `systemctl enable --now sddm`, boot hands the machine to the greeter. If SDDM fails, login loops, or Sway never starts:

1. Switch to another virtual terminal: `Ctrl+Alt+F2` (or F3+)
2. Log in on the text console (getty)
3. `sudo systemctl disable --now sddm`
4. Start Sway from the TTY again (`WLR_RENDERER=pixman sway` in VM if needed)

This restores the pre–step-16 workflow. Keep getty enabled on at least one VT so this path stays available.

### Step 6 — done rule

Package install alone is not completion. `xdg-desktop-portal` units may show `loaded` / `inactive (dead)` until something uses them — that is normal.

**Done only after VM proof inside a running sway session:**

1. `pacman -Q xdg-desktop-portal-wlr xdg-desktop-portal-gtk qt5-wayland qt6-wayland`
2. `systemctl --user status xdg-desktop-portal` — unit is `loaded` (`inactive (dead)` OK before use)
3. In Chromium (`$mod+b` / `chromium`): `Ctrl+O` → a file Open dialog appears; afterward `xdg-desktop-portal` may be `active`

**Not required for step 6:** `xdg-desktop-portal-wlr` becoming `active`. That backend serves Screenshot/Screencast for wlroots; prove it when testing screen share or screenshot portals (step 11 territory), not the file picker.

### Dual-stack (Arch)

Arch keeps `i3-wm` and existing X11 tools installed as a **fallback session**. Primary desktop is Sway/Wayland. Do not remove `i3-wm` as part of this plan; Ubuntu’s X11 + i3 path is unchanged. Wayland replacement steps (polkit, screenshots, clipboard, launcher, lock) apply to the Sway session only — X11 counterparts may remain installed unused under Sway.

### Display layout

**Chosen:** `kanshi` (autorandr replacement) — profile-based layouts when outputs appear/disappear. Install `kanshi`, `exec kanshi` from sway config, port named profiles from the old autorandr binds. Not required for single-monitor TTY→sway VM work; do it when docking / multi-monitor matters (after core session steps, before or after step 16 as needed).

## Step 4 — sway config port (dotfiles)

Sway reads `~/.config/sway/config`, not `i3/config`. Port from `aspects/dotfiles/files/.config/i3/config`:

| i3 (keep on Ubuntu) | sway (Arch Wayland) |
|---|---|
| `bar { i3status-rs }` | sway `bar {}` + i3status-rs (now); waybar optional later |
| `feh` wallpaper | `swaybg` |
| `lxpolkit` | `polkit-gnome` |
| `xss-lock` + `i3lock` | `swayidle` + `swaylock` (step 15) |
| `flameshot` | grim/slurp/satty (step 11) |
| `rofi` (`$mod+space`) | `wofi` (step 10) |
| `rofi -dmenu` (`passmenu`) | `wofi --dmenu` (step 13; after store + `wl-clipboard`) |
| `gromit-mpx` | deferred — no Wayland replacement chosen yet |
| `autorandr` | `kanshi` (chosen — see Display layout) |
| `i3-msg` in scripts | `swaymsg` |

**Carries over unchanged:** most `bindsym`, gaps, colors, scratchpad, app launch binds, `mise r term`.

Shared assets (wallpaper, `startup.sh`, `scratchpad_focused.sh`) can stay under `.config/i3/` and be referenced from sway config.

## Step 2 — gnome-keyring (done)

See [PLAN.hyprland.md](PLAN.hyprland.md#step-2-implementation--gnome-keyring-libsecret) — same implementation in `aspects/aur/login/`.

## Package cleanup (step 4 — done)

Hyprland stack (`hyprland`, `uwsm`, `xdg-desktop-portal-hyprland`) is already gone from `aspects/aur/packages`. That file installs `sway`, `swaybg`, `mako`, `libnotify`, `i3status-rust`, `alacritty`, plus `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gtk`, `qt5-wayland`, `qt6-wayland`.

Keep `i3-wm` on Arch as a fallback session (see Dual-stack above). Do not drop it in this plan.

## docker

**Optional later** — not required to finish the Sway desktop sequence. After step 17 if desired. Omarchy source: `install/config/docker.sh` — install `docker` + `docker-compose`, enable `docker.socket`, add user to `docker` group.

## printing

**Optional later** — not required to finish the Sway desktop sequence. After step 17 if desired. Omarchy source: `install/config/hardware/printer.sh` — `cups`, `avahi`, `cups-pdf` + services.

## omarchy-iso contract

Unchanged — see [PLAN.hyprland.md](PLAN.hyprland.md#omarchy-iso-contract). Package lists should follow **this** plan when building ISO mirrors.

# Lookup

- Sway i3 compatibility: https://github.com/swaywm/sway/wiki/i3
- Omarchy (boot/login reference only): ~/code/ghq/github.com/basecamp/omarchy/
- i3 config source: `aspects/dotfiles/files/.config/i3/config`
- Omarchy iso: ~/code/ghq/github.com/omacom-io/omarchy-iso/
