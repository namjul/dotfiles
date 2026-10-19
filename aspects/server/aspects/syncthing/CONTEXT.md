# Syncthing Hub (homelab)

Runs the official `syncthing/syncthing:2.1.6` image in Docker Compose. The Syncthing configuration is stored at `$XDG_CONFIG_HOME/syncthing` and synced file data is stored at `$XDG_DATA_HOME/syncthing`. Caddy serves the GUI at `https://sync.homelab.xyz/`.

## Network policy

The GUI is published only on `127.0.0.1:8384` and is reached through Caddy. TCP and UDP port `22000` are published only on `DNS_SERVER_IP`, the Pi's Tailscale address. The entrypoint disables global discovery, local discovery, relays, and NAT traversal, then keeps only `tcp://0.0.0.0:22000` and `quic://0.0.0.0:22000` as container listeners.

The host publish address is the network boundary. A LAN client that is not on the tailnet must not reach the GUI or port `22000`.

## Credentials

Set `GUI_AUTH` in `aspects/syncthing/mise.toml` before deployment. It is templated into `$XDG_CONFIG_HOME/syncthing/compose.env` with mode `0640` and group `homelab`. `GUI_AUTH` is split at the first colon, so the password may contain additional colons.

The entrypoint runs `syncthing generate` on every container start to enforce the configured GUI credentials without replacing the existing device certificate, devices, or folders. It does not create or delete devices or folders.
After generation, it reads the persisted GUI API key from `config.xml` and passes it through `STGUIAPIKEY` for the policy CLI calls; the key is not derived from `GUI_AUTH`.
It also declines anonymous usage reporting (`uraccepted=-1`) so the GUI does not show the usage-reporting prompt.

## Deploy

```bash
cd aspects/server
mise run converge
```

The compose project is `$XDG_CONFIG_HOME/syncthing/compose`, and the deployed files are `compose.yaml`, `entrypoint.sh`, and `compose.env`. The compose environment includes the SHA-256 of `entrypoint.sh`; a changed hash makes Docker Compose recreate the container so the new entrypoint runs, while changes to other deployed files do not trigger that recreation. This aspect uses Docker Compose through `[bootstrap.compose.syncthing]`; it does not create a host systemd unit.

## Verify

```bash
cd aspects/server
mise run health
ssh root@homelab 'ss -lntu | grep 22000'
ssh root@homelab 'ss -lnt | grep 8384'
ssh root@homelab 'docker exec syncthing syncthing cli config options global-ann-enabled get'
ssh root@homelab 'docker exec syncthing syncthing cli config options local-ann-enabled get'
ssh root@homelab 'docker exec syncthing syncthing cli config options relays-enabled get'
ssh root@homelab 'docker exec syncthing syncthing cli config options natenabled get'
curl -sk -o /dev/null -w '%{http_code}\n' https://sync.homelab.xyz/
curl -sk -u 'user:pass' -o /dev/null -w '%{http_code}\n' https://sync.homelab.xyz/
getent hosts sync.homelab.xyz
```

Expected results are `false` for each network policy option, `-1` for `uraccepted`, `401` for the unauthenticated curl, `200` for the authenticated curl, and the current Tailscale IPv4 address for the DNS lookup. The `ss` output must show the configured Tailscale address for port `22000` and `127.0.0.1:8384` for the GUI.

After adding a device and folder through the GUI or REST API, run `mise run converge` again and confirm both remain present. A converge must also restore the network policy options, the usage-reporting preference, and the configured GUI password.

## Does not do

This aspect does not edit `10-env.fish`, move or copy `~/Dropbox`, remove `aspects/dropbox`, pair a phone, create `/srv/sync/nam`, create a default folder, or create folders named `memex`, `backup`, `data`, `opt`, or `inbox`.

## Related

- Server routing: `../CONTEXT.md`
- DNS records: `../dns/CONTEXT.md`
- Replacement story: `../../../../docs/stories/replace-dropbox.md`
