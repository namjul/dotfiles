# CoreDNS (homelab)

Runs CoreDNS in Docker on the Pi's Tailscale interface. It provides private
records for `homelab.xyz` and forwards all other DNS queries to Cloudflare.

The records use the homelab Pi's Tailscale IPv4 address configured in
`mise.toml`:

```text
anki.homelab.xyz   → 100.121.171.33
budget.homelab.xyz → 100.121.171.33
```

## Deploy

```bash
cd aspects/server
mise run converge
```

The Pi must already be joined to Tailscale before convergence and
`DNS_SERVER_IP` must match its Tailscale IPv4 address.

## Tailscale DNS

In the Tailscale admin console, add the Pi's Tailscale IPv4 as a restricted
nameserver for `homelab.xyz`. Clients must accept Tailscale DNS settings:

```bash
tailscale set --accept-dns=true
```

The DNS server does not create Tailscale DNS settings automatically. The
restricted nameserver and route are configured in the Tailscale admin console.

## Verify

```bash
ssh root@$SERVER 'docker ps --filter name=coredns'
ssh root@$SERVER 'docker logs coredns --tail 50'
getent hosts anki.homelab.xyz
getent hosts budget.homelab.xyz
```

The last two commands should return the Pi's Tailscale IPv4 address after the
restricted nameserver is configured.
