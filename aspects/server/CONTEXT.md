# server

Manages the homelab host (`SERVER`, default `homelab`). Workspace root is `SQUARE_PATH` (default `/srv/square`). Structured as a monorepo of aspects — the same pattern as the top-level dotfiles repo.

## Aspects (homelab)

**Active** aspects live under `files/srv/square/aspects/` (only what you deploy with `up`). **Legacy / VPS** definitions are in `files/srv/square/archive/` — move or copy an aspect into `aspects/` when you need it on the Pi.

Most aspects use `mise.toml`, `default`, optional `pitchfork.toml`, and optional route snippets. **Caddy** is config-only under `aspects/caddy/` (no aspect `default`): binary, unit, and `caddy.service` install are **bootstrap**; **`up`** syncs `Caddyfile` and routes.

Bootable homelab daemons use [Pitchfork](https://pitchfork.jdx.dev/): `[daemons.*]` and `boot_start` live only in each aspect’s `pitchfork.toml`. Namespace registry: `files/root/.config/pitchfork/config.toml` → `/root/.config/pitchfork/config.toml` via `init` (`[namespaces.<aspect>]` + `config` → aspect `pitchfork.toml`; no duplicated daemon stanzas). **`up`** rsyncs **`aspects/`** and **`.mise.toml`**; **`sync:all`** runs **`init`** then **`up`** (full deploy). Pitchfork restarts in **`up`** after rsync. Host mise tools (`caddy`, …) live in **`aspects/server/mise.toml` `[tools]`** (bootstrap on **`converge`**); square `.mise.toml` is monorepo metadata only. `init` runs `mise trust` / `install` from `$SQUARE_PATH` for aspect tools. Active homelab aspects: `anki` (sync server on **Pitchfork** — see `files/srv/square/aspects/anki/CONTEXT.md`); **Caddy** (HTTPS edge — see `files/srv/square/aspects/caddy/CONTEXT.md`). **Tailscale:** `tailscaled` install and service via bootstrap on **`converge`**; tailnet join from laptop **`tailscale:join`**. Laptop SSH ops (`reboot-if-required`, `tailscale:status`, `caddy:root-ca`, …) live in **`aspects/server/mise.toml`**. **Bootstrap** (packages, sshd, UFW, root lock via `final-hook`) is laptop **`bootstrap remote`** in `aspects/server/mise.toml`; **`converge`** = sync + full bootstrap (see `files/srv/square/tasks/CONTEXT.md`).

## Mise tasks

Set `SERVER` (and optionally `SQUARE_PATH`, default `/srv/square`) per host. Flash / first boot stays manual (`config/user-data.yaml`).

`init` rsyncs `files/root/*` and `files/srv/square/` **except `archive/`** (repo-only legacy). It **does not** rsync `files/etc/` — **`/etc/environment`** and **`/etc/gitconfig`** are written only by **`converge`** (`[bootstrap.files]` in `mise.toml`, templated with `vars.SQUARE_PATH`). **`PUBLIC_KEY`** is appended on the laptop via sops after sync (`init`) and again after bootstrap (`converge`). Per-service `HOME`/`WorkingDirectory` belong in unit files when needed.

`up` substitutes `{SQUARE_PATH}` in staged **`aspects/`** and **`.mise.toml`**, then one filtered rsync to `$SQUARE_PATH/` (`--delete` under `aspects/` only). On the Pi, aspect tasks: **`cd $SQUARE_PATH && mise tasks ls --all`**.

| Task | When |
|------|------|
| `local:prepare` | Laptop: sops SSH keys + ssh client snippet (once per laptop; before first SSH) |
| `sync:all` / `default` | `init` + `up` — square layout and aspects on SERVER |
| `converge` | `sync:all` then full `bootstrap remote homelab` — sole bootstrap entry (all `[bootstrap.*]`) |
| `reboot-if-required` | SSH: reboot if `/var/run/reboot-required` (`aspects/server/mise.toml`) |
| `aspect` | Run a mise task in one aspect on SERVER (`[cmd]` defaults to `default`) |
| `tailscale:join` | Laptop: prompt for one-time auth key → Pi `tailscale up` (stdin; after `converge`) |
| `tailscale:status` | SSH: `tailscale status` + tailnet IPv4 (`aspects/server/mise.toml`) |
| `caddy:root-ca` | `scp` internal CA `root.crt` from SERVER; `--trust` for local p11-kit |

New host: `mise run local:prepare` (once), then `mise run converge`. Day-2: `mise run converge` or `mise run sync:all` alone for aspects-only.

Tailscale join order: `converge` → `tailscale:join` (keep SSH on LAN/public until tailnet SSH works).

## Host convergence layers

Three mechanisms stack; each has a fixed scope. Do not duplicate the same file path in two layers without an explicit migration (see `docs/plans/2026-09-22-server-bootstrap-wave-two.md`).

| Layer | Where defined | Runs from | Delivers |
|-------|----------------|-----------|----------|
| **Bootstrap remote** | `aspects/server/mise.toml` `[bootstrap.*]` + `bootstrap/` | Laptop: `mise run converge` (after `sync:all`) or `mise bootstrap remote homelab …` | Host OS: apt baseline, mise `[tools]` (e.g. `caddy`), `/etc/systemd/system/caddy.service`, `[bootstrap.services.*]` (`docker`, `caddy`, `tailscaled`), `/etc/ssh/sshd_config`, UFW, `final-hook` (SSH restart + `passwd -l root`). Archive is `aspects/server/` only (`source = "."`). |
| **Init + up** | `init`, `up`, `files/root/*`, `files/srv/square/**` (not `files/etc/*`) | Laptop: `sync:all` / `converge` (sync half) | `$SQUARE_PATH` + root profile: square layout, ACLs, aspects, platform task scripts, Pitchfork registry, remote `mise install`, `PUBLIC_KEY` append via sops. Host `/etc/environment` + `/etc/gitconfig` come from bootstrap on **`converge`**, not from `init`. |
| **Laptop SSH ops** | `aspects/server/mise.toml` `[tasks.*]` | Laptop: `mise run reboot-if-required`, `tailscale:status`, `caddy:root-ca`, … | Remote shell over SSH; not square monorepo tasks. |

**Entrypoints:** New host — `local:prepare`, then `converge`. Day-2 aspects — `sync:all` alone. Day-2 host + apps — `converge` (accepts full bootstrap cost: upgrades, SSH restart, root lock). Aspect secrets — fnox / `[bootstrap.secrets]` on the aspect (e.g. Seafile), not host bootstrap.

## Routing
| Task | Aspect | Read |
|------|--------|------|
| Caddy HTTPS edge | `caddy` | files/srv/square/aspects/caddy/CONTEXT.md |
| Laptop SSH ops | — | `aspects/server/mise.toml` `[tasks.*]` |
| Anki sync server | `anki` | files/srv/square/aspects/anki/CONTEXT.md |
| Static sites / SSG builds | `website` | files/srv/square/archive/website/CONTEXT.md (when promoted to `aspects/`) |
