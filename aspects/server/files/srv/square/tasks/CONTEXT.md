# tasks (homelab square)

Host platform tasks that run **on the Pi** under `$SQUARE_PATH`. Included from square `.mise.toml` via `[task_config] includes = ["tasks"]`.

From the laptop, run platform tasks through `aspects/server` (`mise run docker`, …), which SSH to `$SQUARE_PATH` and invoke `mise run` here when needed. Host bootstrap (packages, sshd, firewall, `passwd -l root`) is only **`mise run converge`** in `aspects/server/mise.toml` — not square `tasks/` scripts. Narrow slices: `mise bootstrap remote homelab --only …` by hand if needed.

Task `.sh` files and `config/` sync with `mise run up` (alongside `aspects/`).
