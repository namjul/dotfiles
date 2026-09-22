# Caddy (homelab)

HTTPS edge for the Pi. **Not** a square aspect with `default` / aspect `mise.toml` — host binary and systemd are **bootstrap**; routes and main config deploy with **`up`**.

| Piece | Source | Applied by |
|-------|--------|------------|
| `caddy` binary | `aspects/server/mise.toml` `[tools]` | **`converge`** (bootstrap remote, phase tools) |
| `caddy.service` | `files/srv/square/aspects/caddy/caddy.service` (templated) | **`converge`** → `/etc/systemd/system/caddy.service` |
| `Caddyfile` + per-app `caddyfile` snippets | same tree under `aspects/caddy/` and `aspects/*/caddyfile` | **`sync:all`** / **`up`** → `$SQUARE_PATH/aspects/…` |

**Central TLS:** `Caddyfile` defines `homelab { tls internal; import … }` and redirects `http://homelab` → HTTPS. Per-aspect `caddyfile` snippets add only routes (`handle`, `redir`), not `:80` or host blocks.

**Unit:** Root, no `DynamicUser`. `ExecStart`/`ExecReload` use `bash -c 'cd "$SQUARE_PATH/aspects/caddy" && mise exec -- caddy …'`. `XDG_DATA_HOME` is `$SQUARE_PATH/data/share` so PKI lives under `$SQUARE_PATH/data/share/caddy/pki/…` (`mise run caddy:root-ca` on the laptop).

## Deploy / reload

```bash
cd aspects/server
mise run converge          # first time or after [tools] / unit changes
mise run sync:all          # Caddyfile or route snippet only
ssh root@homelab systemctl reload caddy
```

After **`up`**, reload Caddy if the service is already running (e.g. Anki `default` reloads when active).

## Internal CA

Caddy persists the local CA under **`$XDG_DATA_HOME/caddy/pki/authorities/local/`** (homelab: `$SQUARE_PATH/data/share/caddy/pki/authorities/local/`). It **reuses** that root on normal restarts and reloads. A **new** root happens when PKI storage is empty or the data path changes.

```bash
mise run caddy:root-ca              # → ~/.local/share/homelab/caddy-local-root.crt
mise run caddy:root-ca --trust      # + p11-kit on Arch
```
