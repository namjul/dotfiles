# Homelab layout: bootstrap-only deploy (dissolve square, init/up)

- **Status:** implemented (repo); Pi one-time migration still operator-owned
- **Decision owner:** nam (repo operator)
- **Scope:** `aspects/server` — Pi homelab (`SERVER`, default `homelab`); active aspects `anki`, `caddy`; archive repo-only
- **Tier:** comprehensive — **retire the square concept**, repo tree reshape, bootstrap registry, FHS paths, removal of `init` / `up` / `sync:all`
- **Related:** `aspects/server/CONTEXT.md`, prior discussion on XDG vs `/etc/caddy` exceptions

## Goal

Homelab deploy has **one laptop entrypoint**: `mise run converge` → `mise bootstrap remote homelab` only. **Aspects** remain the git unit under `aspects/server/aspects/<name>/` (same pattern as repo-root aspects). **On-host layout** is **FHS-shaped per service** — no `$SQUARE_PATH`, no `/srv/square` workspace, no Pi-side square monorepo, no `square` group as the organizing permission model.

**Dissolve square** means removing, not relocating:

| Retired | Replacement |
|---------|-------------|
| `SQUARE_PATH` / `/srv/square` as deploy root | Explicit absolute paths in bootstrap (`/etc`, `/var/lib/…` per service) |
| `files/srv/square/**` repo mirror | `aspects/server/aspects/**` + `host/` sources |
| Rsync “square layout” (`init` / `up`) | `[bootstrap.files]`, `[bootstrap.directories]`, `[bootstrap.compose]`, hooks |
| `$SQUARE_PATH/aspects/` on Pi | Git aspects stay on laptop; Pi gets only rendered artifacts + minimal compose build dirs |
| `files/srv/square/.mise.toml` (Pi monorepo) | No homelab monorepo checkout on Pi unless explicitly reintroduced later |
| Unix group **`square`**, `SQUARE_GID`, setgid tree under one root | Per-service data dirs + **`homelab`** group (or aspect-specific ownership) only where shared RW is still needed |
| `SQUARE_PATH` in `/etc/environment` | Tool caches via normal **`XDG_*`** / `/var/cache` paths for root, or aspect-local env in units |

Homelab **aspects** (mise, CONTEXT, compose in git) **stay**; the **square brand and directory namespace** go.

## Context & decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Deploy mechanism | **mise bootstrap only** | Idempotent; no second rsync layer |
| Namespace | **No square** | One less indirection; paths read like any Linux server |
| Aspect source in git | `aspects/server/aspects/<name>/` | Aligns with dotfiles `aspects/*` |
| Caddy main config | `/etc/caddy/Caddyfile` | Global daemon |
| Per-aspect HTTP routes | `/etc/caddy/conf.d/<aspect>.caddy` | Vertical slices in git |
| Caddy PKI | `/var/lib/caddy` (`XDG_DATA_HOME`) | Stable CA; not under a custom tree |
| Anki sync data | `/var/lib/anki/sync` | FHS “variable state” for the app |
| Compose secrets | `/var/lib/anki/compose.env` (mode `0640`, group `homelab`) | Secrets beside the Anki service tree, not `data/private/` under square |
| Compose project / build context | `/var/lib/anki/compose/` | `compose.yaml` + `Dockerfile` only; not “aspect workspace” |
| Shared RW for container ↔ host | Group **`homelab`** on data dirs that need it | Replaces `square`; rename + one-time `chgrp` migration on Pi |
| Archive | `aspects/server/archive/` | Never bootstrap |
| `PUBLIC_KEY` | Template into `/etc/environment` | No append-on-SSH |
| Laptop `[tasks.aspect]` | SSH to **`/var/lib/<aspect>/compose`** (compose-backed aspects) | No `cd $SQUARE_PATH/aspects/…` |

## Current state (square era)

| Mechanism | Delivers |
|-----------|----------|
| **`init`** | Rsync `files/` → `/`; **`square`** group; `/srv/square/data/*`; setgid + ACLs; `PUBLIC_KEY` append |
| **`up`** | Rsync `$SQUARE_PATH/aspects/` + `.mise.toml`; bootstrap slice for Anki |
| **`converge`** | `sync:all` + bootstrap |
| **Env** | `SQUARE_PATH`, `MISE_*` under square data, `GOCACHE`, etc. in `/etc/environment` |

Sources: `aspects/server/files/srv/square/aspects/{anki,caddy}/`, archive under `files/srv/square/archive/`.

## Target repo layout

```
aspects/server/
├── CONTEXT.md
├── mise.toml
├── bootstrap/
├── host/etc/                   # /etc/environment, /etc/gitconfig templates
├── aspects/
│   ├── caddy/
│   └── anki/
├── archive/
├── secrets/
├── config/
└── dns/
```

No `files/srv/square/`. No square-named paths in git.

## Target on-host layout (post-square)

```
/etc/caddy/
├── Caddyfile
└── conf.d/
    └── anki.caddy

/etc/environment                # SERVER-facing vars; no SQUARE_PATH
/etc/systemd/system/caddy.service
/etc/ssh/sshd_config

/var/lib/anki/compose/          # compose.yaml, Dockerfile (build context)
/var/lib/anki/compose.env       # templated compose env
/var/lib/anki/sync/             # Anki sync server data
/var/lib/caddy/                 # Caddy PKI + state

/var/cache/…                    # optional: root tool caches (or XDG defaults)
```

**No `/srv/square`.** After migration, remove stale tree on Pi or leave documented one-time `rm` / archive step.

## Bootstrap registry (pseudostructure)

```toml
[vars]
# homelab-specific deploy vars only — not SQUARE_PATH

[bootstrap.files."/etc/caddy/Caddyfile"]
source = "aspects/caddy/Caddyfile"

[bootstrap.files."/etc/caddy/conf.d/anki.caddy"]
source = "aspects/anki/caddyfile"

[bootstrap.files."/var/lib/anki/compose/compose.yaml"]
source = "aspects/anki/compose.yaml"
# … Dockerfile

[bootstrap.directories."/var/lib/anki/sync"]
group = "homelab"
mode = "2770"

[bootstrap.files."/var/lib/anki/compose.env"]
template = true
group = "homelab"
mode = "0640"

[bootstrap.compose.anki]
project_dir = "/var/lib/anki/compose"
env_files = ["/var/lib/anki/compose.env"]

[bootstrap.hooks.post-layout]
run = '''… ensure group homelab; setfacl only where still required …'''
```

Caddy unit: `--config /etc/caddy/Caddyfile`, `Environment=XDG_DATA_HOME=/var/lib/caddy` — no `SQUARE_PATH`, no `WorkingDirectory` under a faux workspace.

## Mapping square + init/up → bootstrap

| Square era | After |
|------------|--------|
| `$SQUARE_PATH/data/share/anki` | `/var/lib/anki/sync` |
| `$SQUARE_PATH/data/private/anki-compose.env` | `/var/lib/anki/compose.env` |
| `$SQUARE_PATH/aspects/anki` | `/var/lib/anki/compose` |
| `$SQUARE_PATH/data/share/caddy/pki/…` | `/var/lib/caddy/caddy/pki/…` |
| `group square` / `SQUARE_GID` | `group homelab` / `HOMELAB_GID` in template if compose still needs `group_add` |
| `init` ACL hook on `/srv/square/data` | Directories + hook on **`/var/lib/anki`**, **`/var/lib/caddy`**, etc. |
| `up` rsync aspects | Bootstrap file list per aspect |
| Pi `mise tasks` at square root | Laptop orchestration; compose aspects use **`/var/lib/<name>/compose/mise.toml`** only |

## Tasks after migration

| Task | Behavior |
|------|----------|
| `converge` | `mise bootstrap remote homelab --yes --update` only |
| **Removed** | `init`, `up`, `sync:all`, env `SQUARE_PATH` |
| `aspect` | SSH paths under **`/var/lib/<aspect>/compose`** |
| `caddy:root-ca` | Remote path under **`/var/lib/caddy/…`** |

Drop `[env] SQUARE_PATH` from `aspects/server/mise.toml` when slices land.

## Migration slices (ordered)

1. **Plan** (this doc).
2. **Caddy:** `/etc/caddy` + `/var/lib/caddy`; unit without square env; migrate PKI from old path if present.
3. **Repo flatten:** `files/srv/square/aspects/*` → `aspects/`; archive → `aspects/server/archive/`.
4. **Anki paths:** bootstrap `/var/lib/anki/compose`, `/var/lib/anki/sync`, `/var/lib/anki/compose.env`; compose + Caddy snippet paths; **`homelab`** group.
5. **Environment:** rewrite `/etc/environment` template — remove `SQUARE_PATH`, `MISE_*` under square; use XDG/FHS for root tool caches.
6. **Dissolve scripts:** delete `init`, `up`; `converge` = bootstrap only.
7. **Dissolve square on Pi:** one-time data migration `/srv/square/data/share/anki` → `/var/lib/anki/sync` (operator); remove `/srv/square` when empty; `groupdel square` / `groupadd homelab` as needed.
8. **Repo cleanup:** delete `files/srv/square/`; grep for `square`, `SQUARE_PATH`, `SQUARE_GID`; update CONTEXT and aspect CONTEXT files.

## Acceptance criteria

- [x] No `SQUARE_PATH`, `/srv/square`, or **`square`** group in active bootstrap, units, or `/etc/environment`.
- [x] No `init` / `up` / `sync:all`.
- [ ] Caddy + Anki work at new paths; Anki sync URL unchanged for clients. *(verify on Pi after `converge`)*
- [ ] Internal CA stable across converge (explicit PKI migration if path moved). *(verify on Pi)*
- [x] `archive/` never deployed.
- [x] `aspects/server/CONTEXT.md` describes **homelab aspects + bootstrap + FHS paths** — not square workspace.

## Non-negotiables

- **Square concept must not survive as a compatibility shim** (no alias `SQUARE_PATH=/srv/square` in templates “for now”).
- One destination path, one mechanism (bootstrap only).
- Pin Caddy data dir before PKI path change.
- Do not change Anki credentials / public URL without operator ack.

## Out of scope (first pass)

- Full **`homelab`** Unix login user with `$HOME` XDG (optional later; root + groups OK for v1)
- Laptop dotfiles
- Promoting archive aspects
- Auto `tailscale:join` in converge

## Path cheat sheet (operator)

| Concern | Git | On Pi |
|---------|-----|--------|
| Aspect slice | `aspects/server/aspects/<name>/` | `/etc/…` and/or `/var/lib/<name>/…` as needed |
| Caddy | `aspects/caddy/Caddyfile` | `/etc/caddy/` |
| Routes | `aspects/<name>/caddyfile` | `/etc/caddy/conf.d/<name>.caddy` |
| TLS | — | `/var/lib/caddy` |
| Anki data | — | `/var/lib/anki/sync` |
| Anki secrets | `mise.toml` `[vars]` | `/var/lib/anki/compose.env` |
