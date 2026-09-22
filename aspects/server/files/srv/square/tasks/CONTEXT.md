# tasks (homelab square)

Platform ops that SSH to the Pi live in **`aspects/server/mise.toml`** (`reboot-if-required`, `tailscale:status`, …). This directory is repo documentation only; nothing here is synced by **`up`**.

Host bootstrap (packages, sshd, firewall, `passwd -l root`) is **`mise run converge`** in `aspects/server/mise.toml`. SSH server config: `aspects/server/bootstrap/sshd_config` (bootstrap remote).
