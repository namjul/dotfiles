# server

Manages the homelab host (`SERVER`, default `homelab`). **Active** homelab aspects live in `aspects/server/aspects/<name>/` (same git-unit pattern as repo-root aspects). **Legacy / VPS** definitions are in `aspects/server/archive/` — never bootstrap; copy into `aspects/` when promoting to the Pi.

Deploy is **bootstrap-only** from the laptop: `mise run converge` → `mise bootstrap remote homelab`. **Daemon config** stays under `/etc` (e.g. Caddy). **Root tool and aspect state** use the **XDG quartet** from `/etc/environment` (`[vars]` in `mise.toml` → templated on converge). Compose aspects declare paths as `$XDG_CONFIG_HOME/<aspect>/…` and `$XDG_DATA_HOME/<aspect>/…` — no `/srv/square`, `/etc/homelab`, or `/opt/homelab`.

## Aspects (homelab)

| Aspect | Role | CONTEXT |
|--------|------|---------|
| **caddy** | HTTPS edge — config via bootstrap to `/etc/caddy/` | `aspects/caddy/CONTEXT.md` |
| **anki** | Anki sync server — Docker via `[bootstrap.compose.anki]` | `aspects/anki/CONTEXT.md` |

**Caddy:** binary and unit from bootstrap; unit loads `EnvironmentFile=-/etc/environment`; PKI at `$XDG_DATA_HOME/caddy/…`. **Anki:** compose at `$XDG_CONFIG_HOME/anki/compose`, env at `$XDG_CONFIG_HOME/anki/compose.env`, sync data at `$XDG_DATA_HOME/anki/sync`. Shared container↔host RW uses Unix group **`homelab`** on the data dir.

**Tailscale:** `tailscaled` via bootstrap on **`converge`**; join from laptop **`tailscale:join`**. Laptop SSH ops live in **`aspects/server/mise.toml`**. Unix group **`homelab`** is declared in **`[bootstrap.groups]`** (before files); root is added via **`post-packages`** (`usermod`, not `[bootstrap.users]` — mise blocks managing `root`).

## Mise tasks

Set `SERVER` per host. Flash / first boot stays manual (`config/user-data.yaml`).

| Task | When |
|------|------|
| `local:prepare` | Laptop: sops SSH keys + ssh client snippet (once; before first SSH) |
| `converge` / `default` | Full `bootstrap remote homelab` — sole deploy entrypoint |
| `reboot-if-required` | SSH: reboot if `/var/run/reboot-required` |
| `aspect` | Run a mise task in `$XDG_CONFIG_HOME/<aspect>/compose` on SERVER |
| `tailscale:join` | Laptop: one-time auth key → Pi `tailscale up` |
| `tailscale:status` | SSH: `tailscale status` + tailnet IPv4 |
| `caddy:root-ca` | `scp` internal CA from `$XDG_DATA_HOME/caddy/pki/…` on SERVER; `--trust` for local p11-kit |
| `health` | SSH smoke checks (caddy, anki, paths) + `curl https://homelab/anki/` from laptop |

New host: `mise run local:prepare`, then `mise run converge`. Day-2: `mise run converge`.

### XDG base directories

`/etc/environment` sets **all four** `XDG_*` variables together (from `aspects/server/mise.toml` `[vars]`, rendered on converge). Values are root’s spec-default literals (`/root/.config`, `/root/.local/share`, …) — not `$HOME`-relative, because `/etc/environment` is not shell-expanded. Aspects and bootstrap paths that need declarations use **`$XDG_CONFIG_HOME` / `$XDG_DATA_HOME`** (or the same literals in bootstrap registry keys). Do **not** set a lone `XDG_*` or mix with per-tool paths (`MISE_DATA_DIR`, `GOCACHE`, …). Units that must match login (e.g. Caddy) use **`EnvironmentFile=-/etc/environment`**, not a single-variable override.

## Host convergence

| Layer | Where | Runs from | Delivers |
|-------|--------|-----------|----------|
| **Bootstrap remote** | `aspects/server/mise.toml` `[bootstrap.*]` + `bootstrap/` | Laptop: `mise run converge` | OS packages, mise `[tools]`, Caddy unit + configs, Anki compose, sshd, UFW, `final-hook` |
| **Laptop SSH ops** | `[tasks.*]` in same `mise.toml` | Laptop | Remote shell over SSH |

**Pi migration (one-time):** move Anki data to `$XDG_DATA_HOME/anki/sync`; migrate Caddy PKI to `$XDG_DATA_HOME/caddy/pki` if needed; copy from `/var/lib/anki/sync` or square paths if present; remove stale trees when empty; replace group **`square`** with **`homelab`**.

## Routing

| Task | Aspect | Read |
|------|--------|------|
| Caddy HTTPS edge | `caddy` | `aspects/caddy/CONTEXT.md` |
| Anki sync server | `anki` | `aspects/anki/CONTEXT.md` |
| Static sites / SSG builds | `website` | `archive/website/CONTEXT.md` (when promoted) |

Design history: `docs/plans/2026-09-23-server-homelab-bootstrap-layout.md`.
