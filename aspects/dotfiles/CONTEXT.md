Creates symlinks from the $HOME directory to the dotfiles in this repo.

## Privilege escalation (Arch / niri session)

Graphical session auth uses **polkit-gnome** (`polkit-gnome-authentication-agent-1.service` on `graphical-session.target`, wired in `aspects/systemd:session`). Omarchy reference: in-shell agent; this repo uses the stock GTK agent — same job for `pkexec`.

### When to use what

| Caller | Mechanism | Why |
|--------|-----------|-----|
| Interactive terminal (foot, `launch-terminal`) | `sudo` | Password prompt belongs on a TTY; keeps your PATH (mise, `~/.local/bin`). |
| Keybind, wofi, waybar click, agent, background poll | **`pkexec`** via a wrapper | No TTY → password `sudo` can hit **pam_faillock** on repeated polls; `sudo` also sanitizes PATH and breaks mise shims. |
| AppImage / self-`sudo` GUI | **Avoid** | Re-exec as root often loses Wayland/X11 auth; prefer **pacman** packages with polkit (e.g. `rpi-imager`). |

Do not use `pkexec` merely because a command changes system state — only when the caller **cannot** use terminal `sudo` safely.

### Patterns in this repo

- **`bin/pkexec-run`** — resolve command to a **real binary** (refuse mise shims), then `pkexec` with `TERM` preserved. Use for TUIs launched from the desktop without docker/socket access.
- **`bin/launch-lazydocker`** — if Docker socket is not writable, `pkexec-run lazydocker` (not `sudo lazydocker`).
- **`bin/omarchy-vpn-waybar`** / **`omarchy-vpn-i3status`** — bar polls use **`sudo -n`** only; if NOPASSWD is not configured, skip the call (never interactive sudo from the bar).

### Hardening rules for new `pkexec` wrappers

1. Elevate a **fixed path or resolved real file**, not a user-writable script under `$HOME`.
2. Resolve tools with **`mise which`** in the **user** process, then pass the resolved path to `pkexec-run` (root must not run mise shims).
3. Preserve **`TERM`** (and only what you need) through `pkexec`; do not assume root keeps your full environment.
4. For complex root re-exec (mount paths, `PKEXEC_UID`), see Omarchy helpers such as `omarchy-windows-vm` — do not copy AppImage-style “sudo the whole Qt app.”

### Verify after login

```bash
systemctl --user is-active polkit-gnome-authentication-agent-1.service
pkexec true
```

Both should succeed; `pkexec true` should show the polkit dialog once.
