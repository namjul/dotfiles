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
