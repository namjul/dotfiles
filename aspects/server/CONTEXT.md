# server

Manages the remote VPS at `hobl.at`. Structured as a monorepo of aspects — the same pattern as the top-level dotfiles repo.

## Aspects
- `actualbudget` — Budget management (Docker Compose)
- `anki` — Flashcard server
- `caddy` — Reverse proxy / HTTPS termination
- `cron` — Scheduled tasks
- `docker` — Docker daemon setup
- `dotfiles` — Server-side dotfiles
- `ejabberd` — XMPP messaging server
- `evolu-relay` — Evolu database sync relay (Node)
- `goatcounter` — Analytics
- `memex` — Knowledge base (Bun/Python)
- `meta` — Smoke tests
- `pdfding` — PDF management (Docker Compose)
- `soft-serve` — Self-hosted git server
- `rss-bridge` — RSS/Atom feed generator (Docker Compose, rss.samho.xyz, port 5010)
- `webhook` — Git push webhook handler (Go)
- `website` — Static site builder
- `wireguard` — VPN

Each aspect follows the same structure: `mise.toml` (tool versions + tasks), `default` script (idempotent setup), optional systemd service file and Caddyfile.

## Mise tasks

Set `SERVER` (and optionally `SQUARE_PATH`) per host. Flash / first boot stays manual (`config/user-data.yaml`).

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
| Static sites / SSG builds | `website` | files/home/square/aspects/website/CONTEXT.md |
