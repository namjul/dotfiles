# server

Manages the homelab host (`SERVER`, default `homelab`). Workspace root is `SQUARE_PATH` (default `/srv/square`). Structured as a monorepo of aspects — the same pattern as the top-level dotfiles repo.

## Aspects (homelab)

**Active** aspects live under `files/srv/square/aspects/` (only what you deploy with `up`). **Legacy / VPS** definitions are in `files/srv/square/archive/` — move or copy an aspect into `aspects/` when you need it on the Pi.

Each aspect follows the same structure: `mise.toml` (tool versions + tasks), `default` script (idempotent setup), optional `pitchfork.toml` for long-lived processes, optional systemd service file and Caddyfile.

Bootable homelab daemons use [Pitchfork](https://pitchfork.jdx.dev/): `[daemons.*]` and `boot_start` live only in each aspect’s `pitchfork.toml`. Namespace registry: `files/root/.config/pitchfork/config.toml` → `/root/.config/pitchfork/config.toml` via `init` (`[namespaces.<aspect>]` + `config` → aspect `pitchfork.toml`; no duplicated daemon stanzas). **`up`** is aspects-only; **`sync:all`** runs **`init`** then **`up`** (full deploy). Pitchfork restarts in **`up`** after aspects rsync. System mise tools/env live in `files/srv/square/.mise.toml` only (no `/etc/mise/config.toml` symlink — mise dedupes by inode and would treat the square monorepo as system config, so `mise tasks ls --all` stays empty). `init` runs `mise trust` / `install` from `$SQUARE_PATH`. Active homelab aspects: `meta` (Pitchfork pilot), `dotfiles` (root `.bashrc` / `.vimrc` via `default`), `tailscale` (`tailscaled` install on Pi; join from laptop — see `files/srv/square/aspects/tailscale/CONTEXT.md`), `caddy` (path-based HTTP :80 — see `files/srv/square/aspects/caddy/CONTEXT.md`).

## Mise tasks

Set `SERVER` (and optionally `SQUARE_PATH`, default `/srv/square`) per host. Flash / first boot stays manual (`config/user-data.yaml`).

`init` rsyncs `files/etc/*` (not mise config — see square `.mise.toml`) and `files/srv/square/` **except `archive/`** (repo-only legacy; slim `/etc/environment`: `SQUARE_PATH` + mise/deno paths, **no global `HOME`**). Per-service `HOME`/`WorkingDirectory` belong in unit files when needed.

`up` substitutes `{SQUARE_PATH}` in staged **`aspects/`** and **`.mise.toml`**, then one filtered rsync to `$SQUARE_PATH/` (`--delete` under `aspects/` only). On the Pi, list or run all aspect tasks with **`cd $SQUARE_PATH && mise tasks ls --all`** / **`mise run --all`** (same monorepo model as dotfiles root `.mise.toml`).

| Task | When |
|------|------|
| `local:prepare` | Laptop: sops SSH keys + ssh client snippet |
| `sync:all` / `default` | `init` + `up` — square layout and aspects on SERVER |
| `packages` | apt baseline on SERVER; prints note if reboot required |
| `reboot-if-required` | Reboot only when `/var/run/reboot-required` exists |
| `ssh:config` | Deploy `config/sshd_config` if changed |
| `root-lock` | Lock root console password (after key SSH works) |
| `firewall` | Run `config/ufw.sh` |
| `harden` | ssh:config → root-lock → firewall |
| `base` | packages + sync:all + harden |
| `provision` | local:prepare + base (new host) |
| `aspect` | Run a mise task in one aspect on SERVER (`[cmd]` defaults to `default`) |
| `tailscale:join` | Laptop: prompt for one-time auth key → Pi `tailscale up` (stdin; after `aspect tailscale`) |
| `tailscale:status` | `tailscale status` + `tailscale ip -4` on SERVER |

Homelab example: `SERVER=homelab mise run provision` (after SSH with keys).

Tailscale join order: `sync:all` → `aspect tailscale` → `tailscale:join` (keep SSH on LAN/public until tailnet SSH works).

## Routing
| Task | Aspect | Read |
|------|--------|------|
| Tailscale homelab aspect | `tailscale` | files/srv/square/aspects/tailscale/CONTEXT.md |
| Caddy path routing | `caddy` | files/srv/square/aspects/caddy/CONTEXT.md |
| Static sites / SSG builds | `website` | files/srv/square/archive/website/CONTEXT.md (when promoted to `aspects/`) |
