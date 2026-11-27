# CORS proxy (homelab)

Single-file Node 22 HTTP service behind Caddy. It answers `GET /?url=<encoded>` by fetching the target and returning its body with `content-type` passthrough and `access-control-allow-origin: *`, so browser pages served from `file://` or another origin can read feeds. The app listens on `127.0.0.1:8090`; Caddy serves it at `https://proxy.homelab.xyz/` and binds the site to `DNS_SERVER_IP` (see `../caddy/CONTEXT.md`).

The consumer is the RSS reader at `~/Dropbox/memex/tool.llm.rss.html`, which runs inside the tailnet. The proxy is tailnet-only by design: no public ingress, no Cloudflare, no open proxy on the internet. The previous Deno Deploy app (`proxy.namjul.deno.net`) was suspended and the platform is winding down.

**Platform split:** Caddy on **systemd**; the proxy on **systemd** (`proxy.service`, `ExecStart` via `mise exec node`). Node 22 comes from the server aspect's `[tools]`.

## Deploy

```bash
cd aspects/server
mise run converge
```

`[bootstrap.files]` in this folder's `mise.toml` installs the script, unit, and Caddy snippet; `[bootstrap.services.proxy]` enables and starts the unit. Changing `server.mjs` notifies the unit and restarts it (`on_change = "restart"`).

## Verify

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8090/       # 400 Missing url
curl -sk -o /dev/null -w '%{http_code}\n' https://proxy.homelab.xyz/  # 400 Missing url
ssh root@$SERVER 'systemctl status proxy.service --no-pager'
ssh root@$SERVER 'journalctl -u proxy.service -n 50 --no-pager'
```

A real fetch:

```bash
curl -sk 'https://proxy.homelab.xyz/?url=https%3A%2F%2Fwww.youtube.com%2Ffeeds%2Fvideos.xml%3Fchannel_id%3DUC1FD7JbC1p6PvlL0NBIiDtQ' | head -c 200
```

## Hardening (next round)

Verbatim port first; these are the open items, also marked as `TODO(hardening)` in `server.mjs`:

- Pass through the upstream status instead of always returning 200, so the consumer's `res.ok` check works.
- Abort the upstream fetch after a timeout.
- Reject loopback, RFC1918, CGNAT/tailnet, link-local, and `.local`/`.internal` hosts so the proxy cannot be used as a tailnet-internal SSRF gadget.

## Related

- Server routing: `aspects/server/CONTEXT.md`
- Caddy: `aspects/server/aspects/caddy/CONTEXT.md`
