# server

Manages the homelab host (`SERVER`, default `homelab`). Workspace root is `SQUARE_PATH` (default `/srv/square`). Structured as a monorepo of aspects — the same pattern as the top-level dotfiles repo.

## Aspects (homelab)

**Active** aspects live under `files/srv/square/aspects/` (only what you deploy with `up`). **Legacy / VPS** definitions are in `files/srv/square/archive/` — move or copy an aspect into `aspects/` when you need it on the Pi.

Each aspect follows the same structure: `mise.toml` (tool versions + tasks), `default` script (idempotent setup), optional `pitchfork.toml` for long-lived processes, optional systemd service file and Caddyfile.

Bootable homelab daemons use [Pitchfork](https://pitchfork.jdx.dev/): `[daemons.*]` and `boot_start` live only in each aspect’s `pitchfork.toml`. Namespace registry: `files/root/.config/pitchfork/config.toml` → `/root/.config/pitchfork/config.toml` via `init` (`[namespaces.<aspect>]` + `config` → aspect `pitchfork.toml`; no duplicated daemon stanzas). **`up`** rsyncs **`aspects/`**, **`tasks/`**, and **`.mise.toml`**; **`sync:all`** runs **`init`** then **`up`** (full deploy). Pitchfork restarts in **`up`** after rsync. System mise tools/env live in `files/srv/square/.mise.toml` only (no `/etc/mise/config.toml` symlink — mise dedupes by inode and would treat the square monorepo as system config, so `mise tasks ls --all` stays empty). `init` runs `mise trust` / `install` from `$SQUARE_PATH`. Active homelab aspects: `meta` (Pitchfork pilot), `dotfiles` (root `.bashrc` / `.vimrc` via `default`), `tailscale` (`tailscaled` install on Pi; join from laptop — see `files/srv/square/aspects/tailscale/CONTEXT.md`), `caddy` (HTTPS edge on **systemd** — see `files/srv/square/aspects/caddy/CONTEXT.md`), `anki` (sync server container on **Pitchfork** — see `files/srv/square/aspects/anki/CONTEXT.md`). **Host platform** tasks (`docker`, …) live under **`files/srv/square/tasks/`** and run on the Pi; **`aspects/server`** SSH-delegates where needed. **Bootstrap** (packages, sshd, UFW, root lock via `final-hook`) is laptop **`bootstrap remote`** in `aspects/server/mise.toml`; **`converge`** = sync + full bootstrap (see `files/srv/square/tasks/CONTEXT.md`).

## Mise tasks

Set `SERVER` (and optionally `SQUARE_PATH`, default `/srv/square`) per host. Flash / first boot stays manual (`config/user-data.yaml`).

`init` rsyncs `files/etc/*` (not mise config — see square `.mise.toml`) and `files/srv/square/` **except `archive/`** (repo-only legacy; slim `/etc/environment`: `SQUARE_PATH` + mise/deno paths, **no global `HOME`**). Per-service `HOME`/`WorkingDirectory` belong in unit files when needed.

`up` substitutes `{SQUARE_PATH}` in staged **`aspects/`**, **`tasks/`**, and **`.mise.toml`**, then one filtered rsync to `$SQUARE_PATH/` (`--delete` under `aspects/` and `tasks/` only). On the Pi, list platform tasks with **`cd $SQUARE_PATH && mise tasks ls`**; aspect tasks with **`mise tasks ls --all`**.

| Task | When |
|------|------|
| `local:prepare` | Laptop: sops SSH keys + ssh client snippet (once per laptop; before first SSH) |
| `sync:all` / `default` | `init` + `up` — square layout and aspects on SERVER |
| `converge` | `sync:all` then full `bootstrap remote homelab` — sole bootstrap entry (all `[bootstrap.*]`) |
| `reboot-if-required` | SSH → Pi `tasks/reboot-if-required.sh` |
| `docker` | SSH → Pi `tasks/docker.sh` |
| `aspect` | Run a mise task in one aspect on SERVER (`[cmd]` defaults to `default`) |
| `tailscale:join` | Laptop: prompt for one-time auth key → Pi `tailscale up` (stdin; after `aspect tailscale`) |
| `tailscale:status` | SSH → Pi `tasks/tailscale-status.sh` |
| `caddy:root-ca` | `scp` internal CA `root.crt` from SERVER; `--trust` for local p11-kit |

New host: `mise run local:prepare` (once), then `mise run converge`. Day-2: `mise run converge` or `mise run sync:all` alone for aspects-only.

Tailscale join order: `sync:all` → `aspect tailscale` → `tailscale:join` (keep SSH on LAN/public until tailnet SSH works).

## Routing
| Task | Aspect | Read |
|------|--------|------|
| Tailscale homelab aspect | `tailscale` | files/srv/square/aspects/tailscale/CONTEXT.md |
| Caddy path routing | `caddy` | files/srv/square/aspects/caddy/CONTEXT.md |
| Host platform (tasks) | — | `files/srv/square/tasks/CONTEXT.md` |
| Anki sync server | `anki` | files/srv/square/aspects/anki/CONTEXT.md |
| Static sites / SSG builds | `website` | files/srv/square/archive/website/CONTEXT.md (when promoted to `aspects/`) |
