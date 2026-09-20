# server

Manages the homelab host (`SERVER`, default `homelab`). Workspace root is `SQUARE_PATH` (default `/srv/square`). Structured as a monorepo of aspects — the same pattern as the top-level dotfiles repo.

## Aspects (homelab)

**Active** aspects live under `files/srv/square/aspects/` (only what you deploy with `up`). **Legacy / VPS** definitions are in `files/srv/square/archive/` — move or copy an aspect into `aspects/` when you need it on the Pi.

Each aspect follows the same structure: `mise.toml` (tool versions + tasks), `default` script (idempotent setup), optional `pitchfork.toml` for long-lived processes, optional systemd service file and Caddyfile.

Bootable homelab daemons use [Pitchfork](https://pitchfork.jdx.dev/): `[daemons.*]` and `boot_start` live only in each aspect’s `pitchfork.toml`. Namespace registry: `files/root/.config/pitchfork/config.toml` → `/root/.config/pitchfork/config.toml` via `init` (`[namespaces.<aspect>]` + `config` → aspect `pitchfork.toml`; no duplicated daemon stanzas). `sync:all` runs **`init` then `up`**. Pitchfork restarts in **`up`** after aspects rsync. Pitchfork is in `files/etc/mise/config.toml`. Pilot: `meta` (`pitchfork restart test` in `default`).

## Mise tasks

Set `SERVER` (and optionally `SQUARE_PATH`, default `/srv/square`) per host. Flash / first boot stays manual (`config/user-data.yaml`).

`init` rsyncs `files/etc/*` and `files/srv/square/` **except `archive/`** (repo-only legacy; slim `/etc/environment`: `SQUARE_PATH` + mise/deno paths, **no global `HOME`**). Per-service `HOME`/`WorkingDirectory` belong in unit files when needed.

`up` substitutes `{SQUARE_PATH}` in **`files/srv/square/aspects/`** only, then rsyncs to `$SQUARE_PATH/aspects/` (with `--delete`).

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
| `aspect` | Run mise in one aspect (`[cmd]` defaults to aspect name) |
| `aspect:default` | Run `default` for one aspect |

Homelab example: `SERVER=homelab mise run provision` (after SSH with keys).

## Routing
| Task | Aspect | Read |
|------|--------|------|
| Static sites / SSG builds | `website` | files/srv/square/archive/website/CONTEXT.md (when promoted to `aspects/`) |
