# Tailscale homelab aspect

- **Status:** proposed
- **Decision owner:** nam (repo operator)
- **Scope:** Pi homelab (`SERVER`, default `homelab`) on `$SQUARE_PATH` (default `/srv/square`); laptop + smartphone on same tailnet via app login (not repo auth key)
- **Tier:** comprehensive — new homelab aspect, sops auth key handling, laptop-orchestrated join

## Goal

Join the Pi to the tailnet with an idempotent square aspect (install + `tailscaled`), a **one-shot join from the laptop** using sops (auth key never plaintext on the Pi or in git), and OpenSSH over the tailnet unchanged. Laptop and phone enroll separately via the Tailscale app; they do not use the repo auth key.

## Context & decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| VPN | Tailscale on Pi; WireGuard deprecated | Mesh + MagicDNS; archive WireGuard is VPS↔desktop, not homelab |
| Auth | One-time auth key in **sops**, join from laptop | Pi stays headless; key not in `mise.toml` or Pi env long-term |
| Auth key | **Ephemeral at join** | One-time key pasted at `tailscale:join` prompt; not stored in dotfiles |
| Subnet router | **Out of v1** | Only needed for LAN devices without Tailscale |
| Tags | **Optional v1** | Solo tailnet works without `tag:homelab`; add when ACLs matter |
| Tailscale SSH | **Off** | Existing OpenSSH + sops keys + optional mosh |
| Public SSH | **Keep ufw allow 22** | Tailnet is additive; lockdown later via `tailscale0` only |
| Join in `provision` / `base` | **No (v1)** | Manual `tailscale:join` after first successful `sync:all` + `aspect tailscale` |
| Laptop dotfiles aspect | **Deferred** | GUI client on laptop/phone; `--accept-routes` only if subnet routing added later |

**Auth key scope:** Used **once for the Pi** at join time. Laptop and smartphone use normal tailnet login, not `auth.yml`.

**Deploy flow (existing):** `aspects/server/up` rsyncs `files/srv/square/aspects/**` to `$SERVER:$SQUARE_PATH/` with `--delete` under `aspects/` only. New `tailscale/` is picked up automatically; no change to square `.mise.toml` required.

**Square aspects (not root fig):** Homelab units are bash + `mise.toml` + `default` under `files/srv/square/aspects/` (see `dotfiles/default`, `meta/default`), not fig `index.ts`. Implementation mirrors sibling trap + `set -Eeuo pipefail` style.

**Join runs on the laptop only:** `tailscale:join` prompts for a one-time auth key (`read -s`) and pipes it to the Pi. No tailscale secret in git. SSH keys remain in `secrets/ssh.yml` via sops.

## Current state

- Active homelab aspects: `meta`, `dotfiles`, `tailscale`, `caddy` under `aspects/server/files/srv/square/aspects/`.
- Generic remote aspect runner: `mise run aspect <name>` → SSH + `mise run default` on Pi (`aspects/server/mise.toml`).
- WireGuard server aspect removed (slice 3); historical docs in `docs/archive/wireguard-vps-tunnel/`. UFW no longer opens `51820/udp`.

## Non-negotiables

- Must not commit plaintext `tskey-*` or log auth keys in shell traces (prefer `sops exec-env` on the laptop; **no `set -x`** in join; do not copy `config/ufw.sh` `-x` pattern for join).
- **Auth key must not appear in SSH remote command argv** on either side (`ps`, audit logs). Join implementation must use a minimal-exposure pattern (e.g. pipe key on stdin to a remote shell that reads into a variable, then runs `tailscale up` locally on the Pi). Do not extend the `init` precedent of expanding secrets into `ssh … "…$var…"` for `auth_key`.
- Pi `default` must **not** run `tailscale up` with a key from disk on the Pi (join stays laptop-orchestrated).
- Do not enable Tailscale SSH or subnet routing in v1 unless explicitly added in a later slice.
- Do not remove public SSH / change `ufw` for Tailscale in the first slice (except WireGuard cleanup slice below).
- Tailscale auth stays in `aspects/server/secrets/` (not rsynced); do not put age/PGP private material on the homelab for this flow.

## Out of scope (first pass)

- `aspects/tailscale/` at dotfiles root for laptop CLI
- ACL/tag policy in Tailscale admin (document only)
- `provision` / `base` calling join automatically
- Tailscale Serve/Funnel as WireGuard VPS replacement

## Technical approach

### Homelab aspect layout

```
aspects/server/files/srv/square/aspects/tailscale/
  mise.toml           # TAILSCALE_HOSTNAME=homelab; no secrets
  default             # install + enable tailscaled; idempotent skip if already installed
  CONTEXT.md          # operator doc: join, revoke key, phone/laptop enrollment
```

**`default` behavior:**

1. Same bash trap pattern as `dotfiles/default` and `meta/default`.
2. If `tailscaled` missing: use official **`curl -fsSL https://tailscale.com/install.sh | sh`** (single supported path in v1; document air-gap failure if install script is unreachable).
3. `systemctl enable --now tailscaled`.
4. **Already-joined predicate (shared with `tailscale:join`):** use `tailscale status --json` and treat as joined when `BackendState` is `Running` (not `NeedsLogin`, `Stopped`, etc.). Pin this check in both `default` and join skip logic—do not rely on vague “LoggedOut false” text parsing across Tailscale versions.
5. If joined per above, exit 0 with message; **do not** call `tailscale up`.
6. If not joined, print that operator must run **`mise run tailscale:join`** from the **laptop** (no key on Pi).

**`mise run --all` on Pi:** Safe only while `default` never calls `tailscale up`. If a `[tasks.join]` is ever added on the Pi, `--all` becomes dangerous—state in `CONTEXT.md`.

**No Pitchfork** — use upstream `tailscaled.service`.

### Laptop tasks (`aspects/server/mise.toml`)

**`tailscale:join`** (new):

- Prompt for one-time auth key on laptop (`read -s`); **never** pass key in the remote SSH command string (pipe → `read` on Pi).
- Always `--hostname=homelab` for MagicDNS (override with `TAILSCALE_JOIN_HOSTNAME` if needed).
- Flow: skip if `BackendState=Running`; `mise run aspect tailscale`; `tailscale up` on Pi via stdin; no `--ssh`, no `--advertise-routes` in v1.

**`tailscale:status`** (optional, small):

- `ssh root@$SERVER tailscale status` (and optionally `tailscale ip -4`).

Use mise `usage` for any new args; do not use bare `$1`.

### Operator workflow

1. Generate **one-time** key in Tailscale admin (reusable only if you will revoke manually).
2. Keep **`SERVER` / SSH on LAN or public IP** until join and tailnet SSH are verified—do not point `SERVER` at MagicDNS-only names before join completes.
3. `SERVER=homelab mise run sync:all` (use `ssh root@$SERVER` style consistently in docs/commands).
4. `SERVER=homelab mise run aspect tailscale`
5. `SERVER=homelab mise run tailscale:join` (paste key at prompt)
6. Verify SSH to Pi via **tailnet IP or MagicDNS** (`ssh root@$SERVER` with updated config, or explicit `100.x`).
7. Enroll laptop/phone via Tailscale app (same tailnet account).
8. Confirm `mise run tailscale:status` (or Pi `tailscale status`) then revoke auth key in admin if one-time.
9. **Then** cut over `SERVER`/SSH config to tailnet-first names if desired.

### SSH / DNS ergonomics (manual, not blocking v1)

After steps 7–10, point `SERVER`/SSH at MagicDNS name or `100.x` (existing `~/.ssh/config` + `config/ssh_client_config` pattern). No code change required for v1 if connecting by IP/name you choose; document ordering above in `tailscale/CONTEXT.md`.

### When subnet routing would matter (future)

Skip v1 unless you need reachability to **LAN IPs without Tailscale** (printer, dumb NAS, another host’s `192.168.x.x`). Services on the Pi itself are reachable via the Pi’s tailnet IP / MagicDNS without subnet routing.

### Tags (future)

Tags label **machines** for ACLs (`tag:homelab`), not people. Laptop/phone stay user-owned devices. Add tags when writing ACL rules or `autoApprovers` for routes—not required for solo v1.

## System impact

- **`up --delete`:** Adding `aspects/tailscale/` is safe; no Pitchfork namespace entry needed.
- **`mise run --all` on Pi:** Safe if `default` never joins without key; only install/enable.
- **UFW:** Unchanged in slice 1; Tailscale default netfilter `on` adds its own rules. If tailnet SSH fails despite successful join, manual checklist should note **ufw + `tailscale0`** (e.g. `ufw allow in on tailscale0`) as diagnostic/future slice—not required v1 code.
- **WireGuard removal:** Separate slice avoids mixing “add VPN” with “delete legacy port/rule.”

## Implementation slices

### Slice 1: Homelab aspect (install only)

- Add `tailscale/mise.toml`, `default`, `CONTEXT.md`.

Verification:

```bash
cd /home/nam/.dotfiles/aspects/server
mise run sync:all
mise run aspect tailscale
ssh root@$SERVER 'systemctl is-active tailscaled && tailscale version'
```

Review: `default` does not contain auth key or `tailscale up`; matches trap/`set -Eeuo pipefail` style of sibling bash aspects (not fig `index.ts`).

### Slice 2: Join + status tasks

- Add `tailscale:join` and `tailscale:status` to `aspects/server/mise.toml`.
- Update `aspects/server/CONTEXT.md` task table and active-aspects list (`tailscale`).
- Wire `tailscale/CONTEXT.md` to server routing (enrollment split, revoke lifecycle, **no Tailscale SSH** in admin console, laptop-only join, `--all` safety).

**Slice 2 acceptance (design, pre-code):**

- Document chosen join transport: auth key never in SSH remote argv; stdin-or-equivalent on Pi.
- Same **already-joined predicate** as slice 1 (`BackendState` via `tailscale status --json`).
- Hostname precedence: sops → `TAILSCALE_HOSTNAME` → `homelab`.

Verification (with real encrypted key; laptop must be on tailnet before ping):

```bash
cd /home/nam/.dotfiles/aspects/server && mise run tailscale:join
cd /home/nam/.dotfiles/aspects/server && mise run tailscale:status
# Enroll laptop Tailscale app first, then from laptop on tailnet:
tailscale ping homelab
```

Review: join idempotent when already connected; sops path on laptop only; no `set -x` or argv key exposure; clear errors on expired key / SSH failure.

### Slice 3: WireGuard deprecation cleanup

- **Before delete:** confirm nothing still depends on `archive/wireguard/` (VPS↔desktop tunnel docs). If history matters, move to `docs/` outside the deploy tree instead of delete-only.
- Remove `51820/udp` from `aspects/server/config/ufw.sh`.
- Delete `aspects/server/files/srv/square/archive/wireguard/` once obsolete (default after successful homelab tailnet join if VPS tunnel is retired).
- Grep repo for `51820` / wireguard references in server docs; update or remove.

Verification:

```bash
grep -r wireguard aspects/server || true
grep 51820 aspects/server/config/ufw.sh && exit 1 || true
```

Review: no active deploy path references WireGuard; firewall script still allows 22/80/443 as today.

## Test strategy

- No new automated test harness expected for bash/mise homelab aspects (consistent with `meta` / `dotfiles`).
- Manual checklist in `tailscale/CONTEXT.md`: join (LAN SSH first), reboot Pi, `tailscale status`, SSH over tailnet IP/DNS, laptop app enrolled, `tailscale ping homelab`, phone app sees `homelab`; ufw/`tailscale0` note if tailnet SSH fails.

## Documentation strategy

- **`aspects/server/files/srv/square/aspects/tailscale/CONTEXT.md`:** enrollment split (Pi key vs laptop/phone app login), auth key lifecycle (one-time, revoke after confirm status), join **from laptop only**, when to add tags/subnet router, explicit “no Tailscale SSH,” `SERVER` cutover ordering, optional ufw/`tailscale0` troubleshooting.
- **`aspects/server/CONTEXT.md`:** list `tailscale` in active aspects; document `tailscale:join` / `tailscale:status` and ordering after `sync:all`.

## Skills to use (implementation)

- **manage-aspects** — slice 1 layout and conventions.
- **code** — implement scripts/tasks.
- **expectations** — after first successful join, capture sops-path or Pi OS gotchas in CONTEXT if non-obvious.
- **git-commit** — when committing (Living Systems prefix, scope `server` or `tailscale`).

## Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Auth key in shell history/logs/remote argv | `sops exec-env` on laptop; stdin (or equivalent) on Pi; no `set -x`; no secret in `ssh "…$auth_key…"` |
| Join re-run with expired key | Shared JSON `BackendState` predicate before `up`; clear error if `up` fails |
| Sops rule mismatch on nested path | Slice 1 gate: `sops -d` (and encrypt round-trip) from `aspects/server` before commit |
| SSH breaks mid-migration | Join while `SERVER` uses LAN/public; tailnet SSH verified before MagicDNS-only `SERVER` |
| ufw vs tailscale0 | Document diagnostic; optional future `ufw allow in on tailscale0` slice |
| Pi reboot | `tailscaled` enabled; no re-join unless logout/reimage |
| Operator expects laptop to use same secret | CONTEXT states Pi-only key |

## Future work

- `tag:homelab` + ACL samples when tightening access.
- Subnet router: IP forwarding + `--advertise-routes` + `autoApprovers` + laptop `--accept-routes`.
- `ufw allow in on tailscale0` and drop public 22.
- Dotfiles-root `aspects/tailscale` for laptop CLI flags.
- Optional `tailscale:join` in `provision` after stable idempotency.

## Open questions

1. **WireGuard slice timing:** Same PR as slice 1–2 or immediately after first successful join? **Default:** slice 3 right after slice 2 if homelab SSH no longer depends on VPS tunnel.
2. **Encrypted placeholder in git:** Commit empty encrypted `auth.yml` vs gitignore and document creation-only? **Resolved:** commit encrypted file with `auth_key: REPLACE_ME` replaced locally before join (mirrors `ssh.yml` pattern).
3. **Hostname in admin console:** Fixed `homelab` in `mise.toml` env vs only in `auth.yml`? **Resolved:** join task order **sops `hostname` → `TAILSCALE_HOSTNAME` in `mise.toml` → `homelab`** (encode in join script, not docs-only).
