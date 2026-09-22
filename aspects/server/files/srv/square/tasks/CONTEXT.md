# tasks (homelab square)

Host platform tasks that run **on the Pi** under `$SQUARE_PATH`. Included from square `.mise.toml` via `[task_config] includes = ["tasks"]`.

From the laptop, run platform tasks through `aspects/server` (`mise run docker`, `mise run harden`, …), which SSH to `$SQUARE_PATH` and invoke `mise run` here. **`packages`** is laptop-only: `aspects/server` `mise run packages` → `bootstrap remote` (not a square `tasks/` script).

Task `.sh` files and `config/` sync with `mise run up` (alongside `aspects/`).
