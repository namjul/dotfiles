# Caddy (homelab)

**Central TLS:** `Caddyfile` defines `homelab { tls internal; import … }` and redirects `http://homelab` → HTTPS. Per-aspect `caddyfile` snippets add only routes (`handle`, `redir`), not `:80` or host blocks.

**Routes:** e.g. `meta/caddyfile` → `/test/*` → `127.0.0.1:8100`

**Binary:** `caddy` tool in aspect `mise.toml` ([mise install](https://caddyserver.com/docs/install#mise)); `default` runs `mise install` + `mise exec -- caddy version`.

**Unit:** Root, no `DynamicUser`. `ExecStart`/`ExecReload` use `bash -c 'cd "$SQUARE_PATH/aspects/caddy" && mise exec -- caddy …'` (same pattern as `meta/test.service`; archived `mise exec` failed with `DynamicUser` + sandbox). `XDG_DATA_HOME` / `XDG_CONFIG_HOME` match `mise.toml` and the unit so PKI lives under `$SQUARE_PATH/data/share/caddy/pki/…` (export `…/pki/authorities/local/root.crt` for browser trust).

## If `curl -k https://homelab/test/` is empty

1. **Port 443 down** → fix `systemctl status caddy`, not the route.
2. **Backend up** → `curl http://homelab:8100/` should list files first.
3. Deploy order: `mise run sync:all` then `mise run aspect caddy`.

## Deploy

```bash
cd aspects/server
mise run sync:all
mise run aspect caddy
curl -k -s https://homelab/test/
```

Trust Caddy’s internal CA on clients if you want browsers without warnings (`tls internal`).

## Internal CA — when a **new** root is minted

Caddy persists the local CA under **`$XDG_DATA_HOME/caddy/pki/authorities/local/`** (homelab: `$SQUARE_PATH/data/share/caddy/pki/authorities/local/`). It **reuses** that root on normal restarts, reloads, and Caddy upgrades. A **new** root CA (new `root.crt` / new trust on laptops) happens when Caddy **first creates** PKI in a storage location, or **cannot load** the existing root key+cert there.

| Cause | What happened |
|--------|----------------|
| **First `tls internal` in this data dir** | Empty `…/pki/authorities/local/` → Caddy generates root + intermediate on first need. |
| **`XDG_DATA_HOME` / storage path changed** | e.g. moved from `/root/.local/share` to `$SQUARE_PATH/data/share` — new dir looks empty → **new CA**; old files remain under the old path until you delete them. |
| **Deleted or renamed PKI** | `rm -rf …/caddy/pki` or `…/authorities/local/*` (often while Caddy is stopped) → next start mints a fresh CA. |
| **New host / restore without PKI backup** | Fresh `$SQUARE_PATH/data/share/caddy` on the Pi. |
| **Different CA id in config** | `tls internal { ca <name> }` uses `pki/authorities/<name>/` — switching name is a **separate** CA tree, not a rotation of `local`. |
| **Separate Caddy process + separate storage** | Second data directory (another user, container, or machine) → independent CA. |

**Does *not* mint a new root:** `systemctl restart caddy`, `caddy reload`, leaf/intermediate renewal, `caddy untrust` (trust store only), apt → mise binary swap (same data dir).

**Root expiry (~10y default):** Caddy does **not** auto-rotate the root; after expiry you must replace PKI deliberately (backup/remove `authorities/local`, restart) and redistribute `root.crt`.

**Laptop shortcut** (from `aspects/server`):

```bash
mise run caddy:root-ca              # → ~/.local/share/homelab/caddy-local-root.crt
mise run caddy:root-ca --trust      # + p11-kit on Arch
mise run caddy:root-ca ~/Downloads/homelab-ca.crt
```
