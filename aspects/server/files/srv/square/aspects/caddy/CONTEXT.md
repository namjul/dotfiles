# Caddy (homelab)

**Caddyfile (same as VPS):** `import {$SQUARE_PATH}/aspects/*/caddyfile`

**Routes:** e.g. `meta/caddyfile` → `:80` + `/test/*` → `127.0.0.1:8100`

**Unit:** Homelab uses root + `/usr/bin/caddy` (no `DynamicUser` / `mise exec` — that broke `WorkingDirectory` on the Pi). VPS archive unit differs; config import model is the same.

## If `curl http://homelab/test/` is empty

1. **Port 80 down** → `curl: (7) Could not connect` — fix `systemctl status caddy`, not the route.
2. **Backend up** → `curl http://homelab:8100/` should list files first.
3. Deploy order: `mise run sync:all` then `mise run aspect caddy`.

## Deploy

```bash
cd aspects/server
mise run sync:all
mise run aspect caddy
curl -s http://homelab/test/
```
