# Anki Sync Server (homelab)

Runs [anki-sync-server](https://github.com/ankitects/anki) in **Docker** (upstream `docs/syncserver` Dockerfile), supervised by **Pitchfork** (`[daemons.anki]` in `pitchfork.toml`). Data on the host: `$SQUARE_PATH/data/share/anki`. Caddy path route: `caddyfile` → `https://homelab/anki/` (see `../caddy/CONTEXT.md`).

**Platform split:** Caddy stays on **systemd**; Anki is an **app daemon** behind Pitchfork (same class as `meta` test). **Docker Engine** is a host prerequisite (`mise run docker` from `aspects/server`).

## Credentials

Set `SYNC_USER1` in `mise.toml` to `username:password` before deploy. Anki desktop: sync URL `https://homelab/anki/`, same credentials.

Bump release: change `ANKI_VERSION` in `mise.toml` (image build arg), then redeploy.

Sync data stays under the square permission model (`chgrp square`, setgid/ACLs from `init`). The container user `anki` (UID 1000) gets host group **square** via compose **`group_add`**; **`SQUARE_GID`** is resolved in `mise.toml` (`exec` + `getent`) and passed to Compose when Pitchfork runs with **`mise = true`** (and when `mise run default` runs **`docker compose up --build`**).

## Deploy

First host (Docker not installed yet):

```bash
cd aspects/server
mise run sync:all
mise run docker
mise run aspect anki
```

Later updates:

```bash
cd aspects/server
mise run sync:all
mise run aspect anki
```

Requires **caddy** deployed for HTTPS routing. **`aspect anki`** runs **`docker compose up -d --build --remove-orphans`** (idempotent converge) then **`pitchfork restart anki`**. Pitchfork **`run`** does **`up -d --remove-orphans`** then **`logs -f`** (no **`--force-recreate`** — avoids fixed **`container_name`** conflicts on repeat deploys). Compose **`restart: unless-stopped`** keeps the container up across reboots.

**First image build** on the Pi compiles inside the container (long; may fail on arm64 — build on amd64 and load, or use a remote registry, if needed).

## Verify

```bash
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/
ssh root@$SERVER "cd $SQUARE_PATH/aspects/anki && pitchfork status anki"
ssh root@$SERVER 'docker ps --filter name=anki-sync-server'
curl -sk -o /dev/null -w '%{http_code}\n' https://homelab/anki/
```

## Related

- Server routing: `aspects/server/CONTEXT.md`
- Docker install: `mise run docker` from `aspects/server` (runs `$SQUARE_PATH/tasks/docker.sh` on the Pi)
- Local deck harvest: `bin/anki-sync.md` (repo root)
