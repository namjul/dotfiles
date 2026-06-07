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


## Routing
| Task | Aspect | Read |
|------|--------|------|
| Static sites / SSG builds | `website` | files/home/square/aspects/website/CONTEXT.md |
