# Actual Budget (homelab)

Runs Actual Budget in Docker. Host data: **`$XDG_DATA_HOME/actualbudget`**. Caddy serves it at **`https://budget.homelab.xyz/`**.

## Deploy

```bash
cd aspects/server
mise run converge
```

The image version is pinned in `mise.toml`. Bump `ACTUAL_VERSION`, then run `mise run converge`.

The `actualbudget` container receives the `homelab` group through `HOMELAB_GID` so the container can read and write the host data directory. Actual creates its account in the web UI; no password is configured in this repository.

## Migration

Before the first start, copy the legacy data on the Pi from `/srv/square/data/share/actualbudget` into `$XDG_DATA_HOME/actualbudget`. Run this before `mise run converge` or before starting the first container:

```bash
mkdir -p "$XDG_DATA_HOME/actualbudget"
rsync -a /srv/square/data/share/actualbudget/ "$XDG_DATA_HOME/actualbudget/"
chgrp -R homelab "$XDG_DATA_HOME/actualbudget"
chmod 2770 "$XDG_DATA_HOME/actualbudget"
```

Verify the copied data before removing the legacy tree. This repository does not move or delete remote data.

The internal Caddy CA must be trusted on the client, as described in `../caddy/CONTEXT.md`.
