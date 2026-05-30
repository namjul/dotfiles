# aspects/aur plan

Tracks optional package concerns — tools and stacks where package installation is the primary concern, not service configuration.

## Wayland desktop implementation sequence

Arch-only additions. Each step is implemented, committed, and tested before moving to the next. X11 packages (`i3-wm`, `feh`, `xclip`, `xsel`, `wmctrl`) are kept — they remain valid for Ubuntu installations.

| # | What | Concern / Purpose | Test in VM | Notes |
|---|---|---|---|---|
| ~~1~~ | ~~`noto-fonts`, `noto-fonts-emoji`, `man-db`~~ | ~~Typography — system-wide font coverage including emoji and docs~~ | ~~`fc-list \| grep Noto`~~ | ~~No compositor needed~~ |
| 2 | `gnome-keyring`, `libsecret` | Credentials — secure storage for WiFi passwords, SSH keys, app secrets | `gnome-keyring-daemon --version` | No compositor needed |
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

### 1 — Package addition

In `aspects/aur/packages`, add a block after the bluetooth line (both are connectivity-layer system packages):

```bash
sudo pacman -S --needed --noconfirm gnome-keyring libsecret
```

### 2 — Systemd user service

gnome-keyring ships `gnome-keyring-daemon.socket` + `gnome-keyring-daemon.service`. Use socket activation (daemon starts on first D-Bus request):

In `aspects/systemd/index.ts`, enable the socket alongside the other user services:

```bash
systemctl --user enable gnome-keyring-daemon.socket
```

**SSH component conflict**: `ssh-agent.service` in the systemd aspect already owns `SSH_AUTH_SOCK`. gnome-keyring's default components include `ssh`, which would try to bind the same socket. Disable it with a drop-in at `aspects/systemd/files/.config/systemd/user/gnome-keyring-daemon.service.d/no-ssh.conf`:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/gnome-keyring-daemon --foreground --components=pkcs11,secrets --control-directory=%t/keyring
```

Alternative: replace `ssh-agent.service` with gnome-keyring's ssh component entirely (stores passphrases in the keyring, simpler). Defer this decision; the drop-in is the lower-risk first step.

### 3 — PAM and auto-unlock

With SDDM autologin (no password typed), `pam_gnome_keyring.so` cannot unlock the keyring — the systemd `display` concern (step 6 in `aspects/systemd/PLAN.md`) already patches `/etc/pam.d/sddm` to remove those lines, preventing the stale prompt.

**Consequence**: the "Login" keyring starts locked on first boot. First app to request a secret prompts for a keyring password. To make it silent (plaintext storage, acceptable on a single-user machine), set an empty password on the "Login" keyring after the first boot:

```bash
secret-tool store --label='init' _init_ 1  # triggers keyring creation
# then use seahorse to clear the password, or:
python3 -c "
import secretstorage
bus = secretstorage.dbus_init()
col = secretstorage.get_default_collection(bus)
col.unlock()
col.change_password()  # enter empty password when prompted
"
```

This step is manual; document it in the systemd/display concern as a post-install note.

### 4 — Environment propagation

gnome-keyring sets `GNOME_KEYRING_CONTROL` on daemon start. With socket activation under systemd user session, the socket path (`$XDG_RUNTIME_DIR/keyring/control`) is stable and libsecret finds it via D-Bus — no explicit env var propagation needed for Wayland sessions started via UWSM.

### Dependency ordering

Implement after the package install (this step) but enable the socket unit only after `aspects/systemd` is applied. The PAM patch in `systemd/display` must land before the first SDDM-managed login or the keyring password prompt will appear.

### Tests

```bash
gnome-keyring-daemon --version
systemctl --user is-enabled gnome-keyring-daemon.socket
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
