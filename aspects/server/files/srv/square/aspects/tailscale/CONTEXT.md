# Tailscale (homelab square aspect)

Installs and enables upstream `tailscaled` on the Pi. **Joining the tailnet is laptop-orchestrated** (`mise run tailscale:join` in `aspects/server`); this aspect never runs `tailscale up` with an auth key on the Pi.

## Enrollment split

| Device | How it joins |
|--------|----------------|
| Pi (`homelab`) | One-time auth key at join prompt (not stored in dotfiles) |
| Laptop / phone | Tailscale app login (same tailnet account) |

## Auth key

- Generate a **one-time** key in Tailscale admin when you run join.
- Paste at the laptop prompt (`read -s`); the script pipes it to the Pi over SSH stdin (never in the remote command line).
- Do not commit the key. Revoke or let it expire in admin after `tailscale status` looks good.

Join always passes `--hostname=homelab` so the Pi appears as **`homelab`** in MagicDNS (override with `TAILSCALE_JOIN_HOSTNAME` only if you need a different tailnet name). Aspect `TAILSCALE_HOSTNAME` in `mise.toml` documents the same default.

## Operator workflow

1. Generate a one-time key in Tailscale admin.
2. Keep SSH/`SERVER` on LAN or public IP until tailnet SSH works.
3. `mise run sync:all` → `mise run aspect:default tailscale` → `mise run tailscale:join` (paste key when prompted).
4. Verify SSH over tailnet IP or MagicDNS; enroll laptop/phone app; confirm status; revoke key in admin.
5. Optionally point `SERVER`/SSH config at tailnet-first names.

## Already joined

Install and join treat the node as joined when `tailscale status --json` reports `BackendState=Running`.

## Non-goals (v1)

- Tailscale SSH (use OpenSSH + existing keys)
- Subnet router / `--advertise-routes`
- `tailscale up` in this `default` task or any Pi-side join task (do not add `[tasks.join]` on the Pi — `mise run --all` would become unsafe)

## Troubleshooting

- **Air gap:** `default` uses Tailscale’s install script over HTTPS; offline installs need a separate procedure.
- **Tailnet SSH fails but join succeeded:** check ufw vs `tailscale0` (e.g. `ufw allow in on tailscale0`); public SSH on port 22 may still work until lockdown.

## Laptop tasks (`aspects/server`)

| Task | Purpose |
|------|---------|
| `tailscale:join` | Prompt for auth key; `aspect:default tailscale`; `tailscale up` on Pi via SSH stdin |
| `tailscale:status` | Remote `tailscale status` and `tailscale ip -4` |

## Related

- Plan: `docs/plans/2026-09-20-tailscale-homelab-aspect.md`
- Server routing: `aspects/server/CONTEXT.md`
