# Anki Sync Server (homelab)

Runs [anki-sync-server](https://github.com/ankitects/anki) in **Docker** (upstream `docs/syncserver` Dockerfile). Host sync data: **`$XDG_DATA_HOME/anki/sync`**. Caddy path route: `caddyfile` → `https://homelab/anki/` (see `../caddy/CONTEXT.md`).

**Platform split:** Caddy on **systemd**; Anki on **Docker Compose** with `restart: unless-stopped`. **Docker Engine** is a host prerequisite (`converge` enables `docker.service`).

## Credentials

Set `SYNC_USER1` in **`aspects/server/mise.toml`** `[vars]` before deploy (rendered to **`$XDG_CONFIG_HOME/anki/compose.env`** on bootstrap). Anki desktop: sync URL `https://homelab/anki/`, same credentials.

Bump release: change `ANKI_VERSION` in **`aspects/server/mise.toml`** `[vars]`, then `mise run converge`.

Sync data uses group **`homelab`** on **`$XDG_DATA_HOME/anki/sync`** (setgid). Container user `anki` (UID 1000) gets host group **homelab** via compose **`group_add`**; **`HOMELAB_GID`** is resolved in the bootstrap env template and passed through **`compose.env`** (with **`XDG_*`** for compose volume paths).

## Deploy

If converge fails with **`refusing unsafe change to bootstrap compose project 'anki'`**, the Pi still has project **`anki`** from **`/srv/square`**. Once:

```bash
cd aspects/server
mise run anki:retire-square-compose
mise run converge
```

```bash
cd aspects/server
mise run converge
```

Manual task on SERVER (after converge):

```bash
mise run aspect anki
```

Requires **caddy** for HTTPS routing. **`[bootstrap.compose.anki]`** on **`converge`** keeps the container running across reboots.

**First image build** on the Pi compiles inside the container (long; may fail on arm64 — build elsewhere and load if needed).

## Verify

```bash
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/
ssh root@$SERVER 'docker ps --filter name=anki-sync-server'
curl -sk -o /dev/null -w '%{http_code}\n' https://homelab/anki/
```

## Related

- Server routing: `aspects/server/CONTEXT.md`
- Local deck harvest: `bin/anki-sync.md` (repo root)
