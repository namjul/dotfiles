# tasks (homelab square)

Host platform tasks that run **on the Pi** under `$SQUARE_PATH`. Included from square `.mise.toml` via `[task_config] includes = ["tasks"]`.

From the laptop, run the same names through `aspects/server` tasks (`mise run packages`, `mise run docker`, …), which SSH to `$SQUARE_PATH` and invoke `mise run` here.

Task `.sh` files and `config/` sync with `mise run up` (alongside `aspects/`).
