# aspects/aur plan

## Wayland desktop implementation sequence

Arch-only additions. Each step is implemented, committed, and tested before moving to the next. X11 packages (`i3-wm`, `feh`, `xclip`, `xsel`, `wmctrl`) are kept — they remain valid for Ubuntu installations.

**Before marking a step complete:**

1. **Omarchy diff** — compare against the corresponding script in `~/code/ghq/github.com/basecamp/omarchy/`. Surface differences that affect behavior: missing packages, different service configurations, skipped setup steps. Omit cosmetic differences (formatting, comments, ordering). Report findings before marking done.
  - use the `engineering/neovim` skill to mark **Omarchy files only** (`~/code/ghq/github.com/basecamp/omarchy/`): `open` each reference at the compared line, `annotate` MATCH / SKIPPED / DIFF and cite the dotfiles counterpart as text (e.g. `aspects/aur/packages:71`) — do **not** place Shannon marks in this repo; the user reviews Omarchy in Neovim and jumps between marks with `:ShannonNextMark` / `:ShannonPreviousMark` (clear stale marks in each Omarchy buffer first).
2. **VM test** — run the step's verification commands inside a clean Arch VM. Each step lists its own commands in a Tests section below. Mark done only after the VM tests pass.

Sequence follows boot order: sddm → PAM → uwsm → hyprland → runtime components. sddm is installed early (step 3) so PAM is complete, but `systemctl enable sddm` is deferred to step 14 so all preceding steps can be tested via TTY.

| # | What | Concern / Purpose | Test in VM | Notes |
|---|---|---|---|---|
| ~~1~~ | ~~`noto-fonts`, `noto-fonts-emoji`, `man-db`~~ | ~~Typography — system-wide font coverage including emoji and docs~~ | ~~`fc-list \| grep Noto`~~ | ~~No compositor needed~~ |
| ~~2~~ | ~~`gnome-keyring`, `libsecret`~~ | ~~Credentials — secure storage for WiFi passwords, SSH keys, app secrets~~ | ~~`gnome-keyring-daemon --version`~~ | ~~No compositor needed~~ |
| ~~3~~ | ~~`sddm` package + `login` script~~ | ~~Package in `packages`; PAM + SDDM config in `aspects/aur/login` (omarchy `install/login/`)~~ | ~~`pacman -Q sddm`; `grep pam_gnome_keyring /etc/pam.d/sddm` (session only); `systemctl is-enabled sddm` → disabled~~ | ~~Enable deferred to step 14~~ |
| ~~4~~ | ~~`hyprland`, `uwsm`~~ | ~~Compositor + session launcher — uwsm wraps hyprland as a proper systemd user session~~ | ~~`hyprland --version`; `WLR_RENDERER=pixman uwsm start hyprland` from TTY~~ | ~~Software rendering works in VM with pixman~~ |
| 5 | `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`, `qt5-wayland`, `qt6-wayland` | Wayland integration — file pickers, screenshare, Qt app native Wayland | Open file picker inside Hyprland session; `pacman -Q qt6-wayland` | Test inside step 4 session |
| 6 | `polkit-gnome` | Authorization agent — presents GUI dialog when apps request privileged actions | Trigger privilege escalation inside Hyprland (e.g., mount a drive) | Started via `exec-once` in Hyprland config; replaces `lxpolkit` from i3 |
| 7 | `waybar` | Status bar — workspaces, clock, system tray, resource indicators | `waybar --version`; launch inside Hyprland session | First thing to verify inside compositor |
| 8 | `mako` (alongside `dunst`) | Notifications — desktop notification daemon for alerts and system events | `makoctl mode` inside Hyprland; `notify-send test` | dunst stays for Ubuntu |
| 9 | `wofi` or `walker` | App launcher — keyboard-driven application and command launching | Launch via keybind inside Hyprland | Needs compositor running |
| 10 | `grim`, `slurp`, `satty` | Screenshots — capture full screen or region, annotate | `grim /tmp/test.png` inside Hyprland | Needs compositor for screen capture |
| 11 | `wl-clipboard` | Clipboard — Wayland-native copy/paste between apps | `echo test \| wl-copy && wl-paste` inside Hyprland | Needs Wayland session |
| 12 | `pamixer`, `swayosd` (AUR) | Audio OSD — CLI volume control with visual on-screen feedback on key press | `pamixer --get-volume`; trigger volume key | swayosd blocked until paru available |
| 13 | `hypridle`, `hyprlock`, `hyprsunset` | Idle & lock — screen blank on idle, lock screen, color temperature at night | `hypridle -c ~/.config/hypr/hypridle.conf`; manually trigger lock | Needs Hyprland running |
| 14 | `systemctl enable --now sddm` | Login manager activation — sddm takes over boot; full login flow via PAM session | Reboot; verify sddm login screen; log in and confirm gnome-keyring SSH_AUTH_SOCK is set | Full login flow only on real hardware |
| 15 | `power-profiles-daemon` + power systemd concern | Power — auto-switch performance/power-saver profile on AC plug/unplug | Skip guard fires (no battery in VM) | Real hardware for actual profile switching |

## Step 2 implementation — gnome-keyring, libsecret

Provides a D-Bus Secret Service. Apps (Chromium, NetworkManager, vdirsyncer, gopass) query it via libsecret to store and retrieve credentials. Without it, each app either prompts on every access or stores secrets in plaintext.

### 1 — Package addition (`aspects/aur/packages`)

Added after the bluetooth line:

```bash
sudo pacman -S --needed --noconfirm gnome-keyring libsecret
```

### 2 — Default passwordless keyring (`aspects/aur/login`)

gnome-keyring looks for a default keyring on startup. If none exists, the first app to request a secret triggers a "create keyring" dialog asking for a password — blocking silently in the background. Pre-creating a passwordless keyring (`lock-on-idle=false`, `lock-after=false`) means gnome-keyring finds it immediately and auto-unlocks it without prompting.

Two files written to `~/.local/share/keyrings/` (700), overwritten each run (omarchy `default-keyring.sh`):
- `Default_keyring.keyring` (600) — the keyring definition
- `default` (644) — tells gnome-keyring which keyring to use as the default

### 3 — Socket activation + SSH handled by gnome-keyring

gnome-keyring ships `gnome-keyring-daemon.socket` + `gnome-keyring-daemon.service`. Socket activation is used — the daemon starts on the first D-Bus secret request rather than at session start. With a passwordless keyring this is equivalent to PAM session-line startup (omarchy's approach): the keyring auto-unlocks either way.

The separate `ssh-agent.service` was removed. gnome-keyring handles SSH with its built-in `ssh` component — passphrases are stored in the keyring, which is simpler and consistent.

PAM: `aspects/aur/login` removes only the `-auth` and `-password` pam_gnome_keyring lines from `/etc/pam.d/sddm`, keeping `-session`. The session line starts gnome-keyring-daemon at login and sets `SSH_AUTH_SOCK` automatically — matching omarchy's approach.

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

## omarchy-iso contract

### How the ISO uses this repo

omarchy-iso builds a bootable Arch ISO. After archinstall finishes, the configurator runs `arch-chroot` and then calls `install.sh` from a repo specified by two env vars:

```
OMARCHY_INSTALLER_REPO=https://github.com/<user>/dotfiles
OMARCHY_INSTALLER_REF=main
```

The ISO clones that repo, enters the chroot, and runs `bash install.sh`. At the end of `install.sh`, touch `/var/tmp/omarchy-install-completed` — the ISO reboot check looks for exactly that file at `/mnt/var/tmp/omarchy-install-completed`.

### Required file tree

```
install.sh                          # entry point, executed by ISO inside arch-chroot
install/omarchy-base.packages       # packages installed directly by install.sh
install/omarchy-other.packages      # packages for offline mirror (transitive / hardware deps)
default/plymouth/                   # directory must exist (splash screen assets)
bin/omarchy-upload-log              # script ISO calls to upload install logs
```

`install/helpers/all.sh` — referenced by omarchy-base install scripts but **optional**: the omarchy-iso configurator stubs it out automatically if absent.

### Three package lists

| List | Who uses it | Purpose |
|---|---|---|
| archinstall `packages` array | archinstall itself, before `install.sh` runs | Bootstrap minimum: `base-devel`, `git`, `omarchy-keyring`, `snapper`. These are on the live ISO and installed via pacstrap. |
| `install/omarchy-base.packages` | `install.sh` via `pacman -S` | All packages your install script pulls from the internet. This is the primary list. |
| `install/omarchy-other.packages` | Offline mirror build (`pacman -Syw`) | Catch-all for the mirror: transitive deps, hardware-specific packages (nvidia, `linux-firmware-*`), bootstrap packages already installed by pacstrap. The mirror has to have them even if install.sh never explicitly requests them. |

`--needed` in `pacman -S` silently skips already-installed packages, so overlap between lists is harmless at install time. The other-list matters at mirror-build time only.

### What goes in other vs base

- **base**: everything `install.sh` explicitly installs (the content of `aspects/aur/packages` minus paru-commented lines)
- **other**: packages that are pulled in as transitive deps but you want on the offline mirror; hardware variants (`linux-firmware-ath*`, `linux-firmware-rtl*`); packages installed by pacstrap before install.sh runs

Most packages in `aspects/aur/packages` belong in **base**. A transitive dep only needs to be in **other** if it's not already a dep of something in base (i.e., pacman wouldn't pull it automatically). `--needed` makes explicit listing of already-installed transitive deps safe but wasteful; omit them from base unless you want the intent documented.

### install.sh lifecycle

1. archinstall runs, installs the archinstall `packages` array, sets up partitions, bootloader, user
2. ISO arch-chroots into the new system
3. `install.sh` runs as the created user with passwordless sudo
4. Internet is available (live ISO environment has network)
5. `install.sh` finishes → `touch /var/tmp/omarchy-install-completed`
6. ISO detects the file, triggers reboot

`mise install --yes` inside install.sh still requires internet (tool downloads). `curl https://mise.run | sh` can be eliminated since `mise` is in the official Arch repo and can be in the archinstall packages array or `omarchy-base.packages`.

# Lookup

- Omarchy repo: ~/code/ghq/github.com/basecamp/omarchy/
- Omarchy iso repo: ~/code/ghq/github.com/omacom-io/omarchy-iso/
