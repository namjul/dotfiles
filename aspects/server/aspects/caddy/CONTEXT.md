# Caddy (homelab)

HTTPS edge for the Pi. **Not** an aspect with `default` / aspect `mise.toml` on SERVER — host binary and systemd are **bootstrap**; routes and main config deploy via **`converge`**.

| Piece | Git source | On Pi |
|-------|------------|--------|
| `caddy` binary | `aspects/server/mise.toml` `[tools]` | mise (bootstrap tools phase) |
| `caddy.service` | `aspects/caddy/caddy.service` | `/etc/systemd/system/caddy.service` |
| `Caddyfile` | `aspects/caddy/Caddyfile` | `/etc/caddy/Caddyfile` |
| Route snippets | `aspects/<name>/caddyfile` | `/etc/caddy/conf.d/<name>.caddy` |

**Central TLS:** `Caddyfile` defines `homelab { tls internal; import … }` and redirects `http://homelab` → HTTPS. Per-aspect snippets add only routes (`handle`, `redir`).

**Unit:** Root, no `DynamicUser`. **`EnvironmentFile=-/etc/environment`** for the XDG quartet; **`ExecStart`/`ExecReload`** use **`/root/.local/bin/mise exec caddy -- caddy …`** (activate the installed tool by name; systemd’s PATH does not include mise). PKI under **`$XDG_DATA_HOME/caddy/pki/authorities/local/`**.

## Deploy / reload

```bash
cd aspects/server
mise run converge
ssh root@homelab systemctl reload caddy
```

## Internal CA

Caddy persists the local CA under **`$XDG_DATA_HOME/caddy/pki/authorities/local/`** (with homelab defaults: `/root/.local/share/caddy/…`). It **reuses** that root on normal restarts and reloads. A **new** root happens when PKI storage is empty or the data path changes (migrate from old square or `/var/lib/caddy` layout manually if needed).

```bash
mise run caddy:root-ca
mise run caddy:root-ca --trust
```
