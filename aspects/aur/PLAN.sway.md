# aspects/aur plan — Sway (active)

**Target:** Arch + Wayland + **Sway** (i3-compatible WM). Ubuntu keeps X11 + `i3-wm` unchanged.

**Archived Hyprland plan:** [PLAN.hyprland.md](PLAN.hyprland.md)

## Wayland desktop implementation sequence

Arch-only additions. Each step is implemented, committed, and tested before moving to the next. X11 packages (`i3-wm`, `feh`, `xclip`, `xsel`, `wmctrl`) stay for Ubuntu.

**Before marking a step complete:**

1. **Reference diff** — for boot/login steps, compare omarchy `install/login/` where applicable. For Sway-specific steps, use [Sway i3 compatibility](https://github.com/swaywm/sway/wiki/i3) and port from `aspects/dotfiles/files/.config/i3/config` → `aspects/dotfiles/files/.config/sway/config`. Report behavioral gaps only.
2. **VM test** — run verification commands in a clean Arch VM. Mark done only after tests pass.

Sequence: sddm → PAM → sway → runtime components. SDDM installed early (step 3); `systemctl enable sddm` deferred to step 14 so steps 4–13 test from TTY.

| # | What | Concern / Purpose | Test in VM | Notes |
|---|---|---|---|---|
| ~~1~~ | ~~`noto-fonts`, `noto-fonts-emoji`, `man-db`~~ | ~~Typography~~ | ~~`fc-list \| grep Noto`~~ | ~~Shared with hyprland plan~~ |
| ~~2~~ | ~~`gnome-keyring`, `libsecret` + `login/default-keyring.sh`~~ | ~~Credentials~~ | ~~`gnome-keyring-daemon --version`~~ | ~~Done~~ |
| ~~3~~ | ~~`sddm` + `login/sddm.sh` (PAM)~~ | ~~Login manager (not enabled yet)~~ | ~~`pacman -Q sddm`; PAM session line; `systemctl is-enabled sddm` → disabled~~ | ~~SDDM session → sway added in step 4~~ |
| 4 | `sway` (+ swap compositor packages) | Wayland compositor — i3-compatible; port `i3/config` → `sway/config` | `sway --version`; `WLR_RENDERER=pixman sway` from TTY | **Replace** `hyprland`/`uwsm`/`portal-hyprland` in `packages` with `sway`; remove `aspects/dotfiles/.../hypr/` or leave unused |
| 5 | `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gtk`, `qt5-wayland`, `qt6-wayland` | Wayland portals + Qt Wayland | `pacman -Q xdg-desktop-portal-wlr`; portals active inside sway | Swap `portal-hyprland` → `portal-wlr` |
| 6 | `polkit-gnome` | Auth agent for privileged actions | Mount drive / polkit prompt in sway | `exec` in `sway/config`; replaces `lxpolkit` |
| 7 | `waybar` + config | Status bar (replaces i3 built-in bar) | `waybar` shows workspaces in sway session | Sway modules, not hyprland |
| 8 | `mako` | Notifications | `notify-send test` in sway | `dunst` stays on Ubuntu |
| 9 | `wofi` or `rofi-wayland` | App launcher | Launch via `$mod+space` equivalent | Replace X11 `rofi` bind |
| 10 | `grim`, `slurp`, `satty` | Screenshots | `grim /tmp/test.png` in sway | Replaces `flameshot` on Arch Wayland |
| 11 | `wl-clipboard` | Wayland clipboard | `wl-copy` / `wl-paste` | Replaces `xclip`/`xsel` on Arch |
| 12 | `pamixer`, `swayosd` (AUR) | Volume OSD | Volume keys show OSD | Natural fit for sway |
| 13 | `swayidle`, `swaylock` | Idle lock | `swaylock` manually; idle blank | Replaces `xss-lock` + `i3lock` |
| 14 | `systemctl enable --now sddm` + sway session | Full login flow | Reboot → SDDM → sway; `SSH_AUTH_SOCK` set | `login/sddm.sh` wayland session when ready |
| 15 | `power-profiles-daemon` + systemd concern | Power profiles | Skip in VM (no battery) | Real hardware |

## Step 4 — sway config port (dotfiles)

Sway reads `~/.config/sway/config`, not `i3/config`. Port from `aspects/dotfiles/files/.config/i3/config`:

| i3 (keep on Ubuntu) | sway (Arch Wayland) |
|---|---|
| `bar { i3status-rs }` | waybar (step 7) |
| `feh` wallpaper | `swaybg` |
| `lxpolkit` | `polkit-gnome` |
| `xss-lock` + `i3lock` | `swayidle` + `swaylock` (step 13) |
| `flameshot` | grim/slurp/satty (step 10) |
| `rofi` | `rofi-wayland` or wofi (step 9) |
| `gromit-mpx` | skip or find Wayland alternative |
| `autorandr` | `kanshi` or sway `output` blocks |
| `i3-msg` in scripts | `swaymsg` |

**Carries over unchanged:** most `bindsym`, gaps, colors, scratchpad, app launch binds, `mise r term`.

Shared assets (wallpaper, `startup.sh`, `scratchpad_focused.sh`) can stay under `.config/i3/` and be referenced from sway config.

## Step 2 — gnome-keyring (done)

See [PLAN.hyprland.md](PLAN.hyprland.md#step-2-implementation--gnome-keyring-libsecret) — same implementation in `aspects/aur/login/`.

## Package cleanup (step 4 prerequisite)

Current `aspects/aur/packages` still has Hyprland stack from archived plan. Step 4 should:

```bash
# remove or stop installing:
# hyprland uwsm xdg-desktop-portal-hyprland

# add:
sudo pacman -S --needed --noconfirm sway
sudo pacman -S --needed --noconfirm xdg-desktop-portal-wlr xdg-desktop-portal-gtk qt5-wayland qt6-wayland
```

Keep `i3-wm` for dual-stack or drop if Arch is Wayland-only.

## docker

Optional. Omarchy source: `install/config/docker.sh` — install `docker` + `docker-compose`, enable `docker.socket`, add user to `docker` group.

## printing

Optional. Omarchy source: `install/config/hardware/printer.sh` — `cups`, `avahi`, `cups-pdf` + services.

## omarchy-iso contract

Unchanged — see [PLAN.hyprland.md](PLAN.hyprland.md#omarchy-iso-contract). Package lists should follow **this** plan when building ISO mirrors.

# Lookup

- Sway i3 compatibility: https://github.com/swaywm/sway/wiki/i3
- Omarchy (boot/login reference only): ~/code/ghq/github.com/basecamp/omarchy/
- i3 config source: `aspects/dotfiles/files/.config/i3/config`
- Omarchy iso: ~/code/ghq/github.com/omacom-io/omarchy-iso/
