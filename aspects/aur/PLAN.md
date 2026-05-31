# aspects/aur plan

Tracks optional package concerns — tools and stacks where package installation is the primary concern, not service configuration.

## Wayland desktop implementation sequence

Arch-only additions. Each step is implemented, committed, and tested before moving to the next. X11 packages (`i3-wm`, `feh`, `xclip`, `xsel`, `wmctrl`) are kept — they remain valid for Ubuntu installations.

**Before marking a step complete:** diff the implementation against the corresponding script in the omarchy repo (`~/code/ghq/github.com/basecamp/omarchy/`). Surface any differences that affect behavior — missing packages, different service configurations, skipped setup steps, etc. Omit cosmetic differences (formatting, comments, ordering). Report findings before marking done.

| # | What | Concern / Purpose | Test in VM | Notes |
|---|---|---|---|---|
| ~~1~~ | ~~`noto-fonts`, `noto-fonts-emoji`, `man-db`~~ | ~~Typography — system-wide font coverage including emoji and docs~~ | ~~`fc-list \| grep Noto`~~ | ~~No compositor needed~~ |
| ~~2~~ | ~~`gnome-keyring`, `libsecret`~~ | ~~Credentials — secure storage for WiFi passwords, SSH keys, app secrets~~ | ~~`gnome-keyring-daemon --version`~~ | ~~No compositor needed~~ |
| 3 | `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`, `uwsm`, `qt5-wayland`, `qt6-wayland` | Wayland integration — file pickers, screenshare, Qt app compat, proper systemd session | `pacman -Q xdg-desktop-portal-hyprland uwsm` | Prerequisites before Hyprland starts |
| 4 | `hyprland` | Compositor — Wayland window manager; everything graphical depends on this | `hyprland --version`; run `WLR_RENDERER=pixman hyprland` in a TTY | Software rendering works in VM with pixman |
| 5 | `polkit-gnome` | Authorization agent — presents GUI dialog when apps request privileged actions | Trigger privilege escalation inside Hyprland (e.g., mount a drive) | Started via `exec-once` in Hyprland config; replaces `lxpolkit` from i3 |
| 6 | `waybar` | Status bar — workspaces, clock, system tray, resource indicators | `waybar --version`; launch inside Hyprland session | First thing to verify inside compositor |
| 7 | `mako` (alongside `dunst`) | Notifications — desktop notification daemon for alerts and system events | `makoctl mode` inside Hyprland; `notify-send test` | dunst stays for Ubuntu |
| 8 | `wofi` or `walker` | App launcher — keyboard-driven application and command launching | Launch via keybind inside Hyprland | Needs compositor running |
| 9 | `grim`, `slurp`, `satty` | Screenshots — capture full screen or region, annotate | `grim /tmp/test.png` inside Hyprland | Needs compositor for screen capture |
| 10 | `wl-clipboard` | Clipboard — Wayland-native copy/paste between apps | `echo test \| wl-copy && wl-paste` inside Hyprland | Needs Wayland session |
| 11 | `pamixer`, `swayosd` (AUR) | Audio OSD — CLI volume control with visual on-screen feedback on key press | `pamixer --get-volume`; trigger volume key | swayosd blocked until paru available |
| 12 | `hypridle`, `hyprlock`, `hyprsunset` | Idle & lock — screen blank on idle, lock screen, color temperature at night | `hypridle -c ~/.config/hypr/hypridle.conf`; manually trigger lock | Needs Hyprland running |
| 13 | `sddm` + display systemd concern | Login — graphical session manager; presents login screen on boot | Files + `systemctl is-enabled sddm` | Full login flow only on real hardware |
| 14 | `power-profiles-daemon` + power systemd concern | Power — auto-switch performance/power-saver profile on AC plug/unplug | Skip guard fires (no battery in VM) | Real hardware for actual profile switching |

## Step 2 implementation — gnome-keyring, libsecret

Provides a D-Bus Secret Service. Apps (Chromium, NetworkManager, vdirsyncer, gopass) query it via libsecret to store and retrieve credentials. Without it, each app either prompts on every access or stores secrets in plaintext.

### 1 — Package addition (`aspects/aur/packages`)

Added after the bluetooth line:

```bash
sudo pacman -S --needed --noconfirm gnome-keyring libsecret
```

### 2 — Default passwordless keyring (`aspects/systemd/index.ts`)

gnome-keyring looks for a default keyring on startup. If none exists, the first app to request a secret triggers a "create keyring" dialog asking for a password — blocking silently in the background. Pre-creating a passwordless keyring (`lock-on-idle=false`, `lock-after=false`) means gnome-keyring finds it immediately and auto-unlocks it without prompting.

Two files written to `~/.local/share/keyrings/` (700), created only if absent:
- `Default_keyring.keyring` (600) — the keyring definition
- `default` (644) — tells gnome-keyring which keyring to use as the default

### 3 — Socket activation + SSH handled by gnome-keyring

gnome-keyring ships `gnome-keyring-daemon.socket` + `gnome-keyring-daemon.service`. Socket activation is used — the daemon starts on the first D-Bus secret request rather than at session start. With a passwordless keyring this is equivalent to PAM session-line startup (omarchy's approach): the keyring auto-unlocks either way.

The separate `ssh-agent.service` was removed. gnome-keyring handles SSH with its built-in `ssh` component — passphrases are stored in the keyring, which is simpler and consistent.

PAM: the `systemd/display` concern removes only the `-auth` and `-password` pam_gnome_keyring lines from `/etc/pam.d/sddm`, keeping `-session`. The session line starts gnome-keyring-daemon at login and sets `SSH_AUTH_SOCK` automatically — matching omarchy's approach.

### Tests

```bash
gnome-keyring-daemon --version
systemctl --user is-enabled gnome-keyring-daemon.socket
ls -la ~/.local/share/keyrings/
```

Inside a running session (Hyprland or plain TTY with dbus-run-session):

```bash
secret-tool store --label='smoke-test' smoke 1
secret-tool lookup smoke 1   # should print: 1
```

## docker

Optional. Only install if Docker is needed for local dev.

Omarchy source: `install/config/docker.sh`

- Install `docker` + `docker-compose`
- Enable `docker.socket` (on-demand activation instead of always-on daemon)
- Add current user to `docker` group
- Configure `systemd-resolved` DNS for containers
- Write Docker daemon config

## printing

Optional. Only install if a printer is available.

Omarchy source: `install/config/hardware/printer.sh`

- Install `cups`, `avahi`, `cups-pdf`
- Enable `cups.service`, `avahi-daemon.service`, `cups-browsed.service`
- No additional config beyond package installation

# Lookup

- Omarchy repo: ~/code/ghq/github.com/basecamp/omarchy/
- Omarchy iso repo: ~/code/ghq/github.com/omacom-io/omarchy-iso/
