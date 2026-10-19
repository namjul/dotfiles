# Plan: Homelab Syncthing hub

**Branch**: feat/syncthing-hub
**Status**: Active

**Tier:** comprehensive — new homelab aspect, tailnet listen address, GUI credentials, and a second converge that must keep devices and folders.

Story: [`docs/stories/replace-dropbox.md`](../stories/replace-dropbox.md). Round 2 (2026-10-17) returned no comments. The map is unchanged.

## Goal

After `mise run converge` from `aspects/server`, the operator can log into an empty Syncthing hub at `https://sync.homelab.xyz`. A later converge keeps devices and folders added in the GUI and writes hub policy again.

## Context & Decisions

| Decision | Why |
|---|---|
| One story, one trunk PR | The rules are policies of one converge. A hub that is up while public relays are still on is not safe to leave running. |
| Copy the Anki fragment, not a fig aspect | Active homelab units are `aspects/server/aspects/<name>/` plus a symlink `aspects/server/.mise/conf.d/<name>`. `manage-aspects` is for repo-root fig aspects. |
| Image `syncthing/syncthing`, tag pinned in `[vars]` | Official image. Config path is `/var/syncthing`, not `/config`. Do not use `latest`. |
| Host publishes ports; the process inside the container listens on all of its interfaces | The Tailscale address and `127.0.0.1` are on the Pi, not inside the container network. Binding the process to `127.0.0.1` inside the container would hide it from Docker's port map and from Caddy. |
| Policy is reapplied by `syncthing generate` plus `syncthing cli` on the running instance | `generate --gui-user --gui-password` updates credentials and leaves the device certificate. The CLI edits live options. Do not replace `config.xml` wholesale on later converges. |
| `DNS_SERVER_IP` stays in the dns aspect | `aspects/server/aspects/dns/mise.toml` already sets it. The syncthing env template reads `{{ vars.DNS_SERVER_IP }}`. Do not copy `100.121.171.33` into the syncthing files. |
| `natEnabled` off | With relays off, NAT-PMP/UPnP could still ask the home router to forward 22000. That would break the rule that a phone off the tailnet does not connect. |
| Credentials match Anki | `GUI_AUTH = "user:pass"` in the syncthing `mise.toml`, templated into `compose.env`. Placeholder, same as `SYNC_USER1`. |

## Current State

- No syncthing aspect. Dropbox still has `aspects/dropbox/`. This plan does not edit it.
- Anki is the pattern: `aspects/server/aspects/anki/mise.toml`, `compose.yaml`, `caddyfile`, symlink `aspects/server/.mise/conf.d/anki` → `../../aspects/anki`. Data dir group `homelab`, mode `2770`. Compose publishes `127.0.0.1:8080:8080`.
- DNS records are the Corefile hosts block in `aspects/server/aspects/dns/Corefile`. `anki` and `budget` point at `{{ vars.DNS_SERVER_IP }}`.
- Caddy imports `/etc/caddy/conf.d/*.caddy` from `aspects/server/aspects/caddy/Caddyfile`. Sites use `tls internal`.
- `aspects/server/mise.toml` `[bootstrap.linux.firewall]` allows 22, 80, 443, 53, and a few others. It does not allow 22000. Incoming default is deny.
- `[tasks.health]` checks anki, actualbudget, and coredns. It does not know about syncthing.
- `[bootstrap.hooks.final]` only restarts ssh and locks the root password. Do not replace that script.

## Non-Negotiables

- `mise run converge` from `aspects/server` is the only deploy step.
- Do not edit `10-env.fish`, move `~/Dropbox`, remove `aspects/dropbox`, pair a phone, or copy `~/Dropbox/memex`.
- Do not create `/srv/sync/nam`, a host systemd unit for Syncthing, or folders named `default`, `memex`, `backup`, `data`, `opt`, or `inbox`.
- Do not publish `0.0.0.0:22000`, host port 8384 on the Tailscale address, or UDP 21027.
- Global discovery, local announce, relays, and NAT stay off after every converge.
- A device and a folder added in the GUI are still listed after the next converge.
- A GUI password change and a GUI discovery change are overwritten by the aspect.

## Technical Approach

### Layout

```
aspects/server/aspects/syncthing/
  mise.toml
  compose.yaml
  caddyfile
  entrypoint.sh
  CONTEXT.md
aspects/server/.mise/conf.d/syncthing -> ../../aspects/syncthing
```

`entrypoint.sh` is bootstrapped to `/root/.config/syncthing/compose/entrypoint.sh` and used as the container entrypoint.

### Compose

- Image: `syncthing/syncthing:${SYNCTHING_VERSION}` with `SYNCTHING_VERSION` pinned in `[vars]`.
- `container_name: syncthing`.
- Env: `STNODEFAULTFOLDER=1`, `STNOUPGRADE=1`, `PUID`/`PGID` so the process can write group `homelab` directories (`PGID` from `HOMELAB_GID`, same `getent` as Anki). `group_add` of `HOMELAB_GID` as well.
- Volumes:
  - `${XDG_CONFIG_HOME}/syncthing:/var/syncthing/config`
  - `${XDG_DATA_HOME}/syncthing:/var/syncthing/data`
- Ports, values from `compose.env`:
  - `127.0.0.1:8384:8384` (GUI)
  - `${DNS_SERVER_IP}:22000:22000/tcp`
  - `${DNS_SERVER_IP}:22000:22000/udp`
- `restart: unless-stopped`. `depends_on` docker, same as Anki.
- Do not set `network_mode: host`.

Inside the container the sync listener is `tcp://0.0.0.0:22000` and `quic://0.0.0.0:22000`. The host publish address is what makes the house LAN have no listener. The GUI process listens on `0.0.0.0:8384` inside the container; Caddy proxies to `127.0.0.1:8384` on the host.

If `DNS_SERVER_IP` is not assigned on the host (tailscaled down), the publish fails and Compose does not fall back to `0.0.0.0`.

### Entrypoint

`entrypoint.sh`:

1. Set `STHOMEDIR` empty and use `STCONFDIR=/var/syncthing/config` plus `STDATADIR=/var/syncthing/data`, overriding the image's inherited home directory without losing the separate persistent mounts.
2. Run `syncthing generate --gui-user=… --gui-password=… --no-port-probing`, splitting `GUI_AUTH` on the first colon.
3. Start `syncthing serve` in the foreground with `--no-browser`, `--no-upgrade`, and `--gui-address=http://0.0.0.0:8384`; `STNODEFAULTFOLDER=1` prevents the default folder.
4. A one-shot child waits until the local GUI answers, reads the generated API key from the persisted `config.xml`, then uses `syncthing cli config` to set, and only set:
   - global announce off
   - local announce off
   - relays off
   - NAT off
   - anonymous usage reporting declined
   - listen addresses to `tcp://0.0.0.0:22000` and `quic://0.0.0.0:22000`
4. The child does not create or delete devices or folders. Discover the exact `cli config` paths with `syncthing cli config --help` on the pinned image and record them in `CONTEXT.md`.
5. Applying an already-correct value is a no-op. A live config change may restart the process; `restart: unless-stopped` brings the container back, and the next pass sees the values already set.

### Bootstrap files

In `aspects/server/aspects/syncthing/mise.toml`, same shape as Anki:

- `[vars] GUI_AUTH = "user:pass"` and `SYNCTHING_VERSION`.
- Caddy snippet → `/etc/caddy/conf.d/syncthing.caddy`.
- Compose file and entrypoint → `/root/.config/syncthing/compose/`.
- Directories `/root/.config/syncthing`, `/root/.config/syncthing/compose`, and `/root/.local/share/syncthing`. Config and data: group `homelab`, mode `2770`. Compose dir: `0755`.
- `compose.env` template: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `HOMELAB_GID`, `DNS_SERVER_IP`, `GUI_AUTH`, `SYNCTHING_VERSION`, and the `entrypoint.sh` SHA-256. Mode `0640`, group `homelab`.
- `[bootstrap.compose.syncthing]` with `env_files`, `state = "running"`, `depends_on = ["service:docker"]`. The changed entrypoint hash triggers container recreation; other deployed file changes do not.

### DNS and Caddy

- `aspects/server/aspects/dns/Corefile`: add `{{ vars.DNS_SERVER_IP }} sync.{{ vars.DNS_DOMAIN }}` beside anki and budget.
- `caddyfile`:

```
sync.homelab.xyz {
	tls internal
	reverse_proxy 127.0.0.1:8384
}
```

### Firewall

After the container is up, from a tailnet peer, check TCP `DNS_SERVER_IP:22000`. If it times out and `ss` on the Pi shows the listener, add UFW allows for TCP and UDP 22000 on the Tailscale interface only. Do not add a rule for every interface. Record the result in `CONTEXT.md`.

### Docs and health

- `aspects/server/aspects/syncthing/CONTEXT.md` in the Anki CONTEXT shape: paths, credentials var, URL, what this aspect does not do, verify commands.
- `aspects/server/CONTEXT.md` and `aspects/server/aspects/dns/CONTEXT.md`: add the aspect and `sync.homelab.xyz`.
- `aspects/server/mise.toml` `[tasks.health]`: container `syncthing` is running; paths exist (`/etc/caddy/conf.d/syncthing.caddy`, compose files, compose.env, data dir); `http://127.0.0.1:8384/` returns a non-`000` code; from the laptop, `https://sync.homelab.xyz/` returns a non-`000` / non-`502` / non-`503` code. Unauthenticated access is expected to be 401. That is a pass.

## System Impact

- CoreDNS and Caddy reload as they already do on converge.
- A bad `entrypoint.sh` crash-loops the syncthing container and does not stop Anki, Actual Budget, or CoreDNS.
- `compose.env` holds the GUI password in plaintext, same exposure as Anki's `SYNC_USER1`.
- A changed `entrypoint.sh` makes the next converge recreate the container. Devices and folders survive because they stay in the mounted `config.xml` and the entrypoint does not rewrite that file.

## Implementation Slices

### Slice 1: After converge, log into an empty tailnet-only hub

**Value**: The operator can open `https://sync.homelab.xyz` and see an empty folder list. A later device can be aimed at `tcp://<DNS_SERVER_IP>:22000` only.
**Path**: `mise run converge` → bootstrap files, Corefile, Caddy snippet, Compose → entrypoint generates config and applies hub policy → GUI via Caddy, sync port on the Tailscale address.
**Class**: Behavior change.
**Delivery**: One independent PR against trunk. Not a stack. Compose, DNS, Caddy, and the entrypoint land together because a partial hub is not safe to leave running.
**Required implementation skills**: `development-guidelines` while editing. `technical-writing` for `CONTEXT.md`. `tdd` is N/A: this repo has no test harness for bootstrap fragments. `mutation-testing` is N/A for the same reason. `manage-aspects` is N/A (fig root aspects).
**Reduction program**: N/A.
**Transition/terminal evidence**: N/A.
**Acceptance criteria**: the story's acceptance criteria, checked by the commands below. Confirm this list before any code.
**RED or preservation baseline**: N/A. There is no failing unit test to write first. The first proof is the verification commands after converge.
**GREEN or preservation change**: the files in Technical Approach, and nothing else.
**REFACTOR**: Only if the entrypoint's CLI calls can be shorter after `--help` is known.
**PRE-PR MUTATION or alternate evidence**: N/A. Evidence is the verification commands on homelab.
**PR-ready when**: every command below passes, and a second converge keeps a device and folder added through the API.
**Slice complete when**: the PR lands.

Verification, from a tailnet machine, after `cd aspects/server && mise run converge`:

```bash
cd /home/nam/.dotfiles/aspects/server
mise run health
ssh root@homelab 'ss -lntu | grep 22000'
ssh root@homelab 'ss -lnt | grep 8384'
ssh root@homelab 'docker exec syncthing syncthing cli config options global-ann-enabled get'
curl -sk -o /dev/null -w '%{http_code}\n' https://sync.homelab.xyz/
curl -sk -u 'user:pass' -o /dev/null -w '%{http_code}\n' https://sync.homelab.xyz/
getent hosts sync.homelab.xyz
```

Expected:

- `health` exits 0.
- `ss` shows `100.121.171.33:22000` for TCP and UDP, or whatever `DNS_SERVER_IP` is that day. It does not show `0.0.0.0:22000` or `*:22000`.
- `ss` shows `127.0.0.1:8384` only.
- global announce prints `false`. Repeat for local announce, relays, and NAT.
- `uraccepted` prints `-1`.
- Unauthenticated curl is `401`. Authenticated curl is `200`.
- `getent hosts sync.homelab.xyz` prints the Tailscale address.

Second converge, on the Pi, using the API key from `config.xml` (do not print the key):

```bash
ssh root@homelab 'python3 - <<"PY"
import json, urllib.request, xml.etree.ElementTree as ET
key = ET.parse("/root/.config/syncthing/config.xml").getroot().find("gui/apikey").text
base = "http://127.0.0.1:8384/rest/config"
def call(method, path, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(base + path, data=data, method=method, headers={"X-API-Key": key, "Content-Type": "application/json"})
    with urllib.request.urlopen(req) as res:
        return res.read()
print(call("PUT", "/devices/ABCDEF-GHIJKLMNOP", {"deviceID": "ABCDEF-GHIJKLMNOP", "name": "spec-device"}))
print(call("PUT", "/folders/spec-memex", {"id": "spec-memex", "label": "memex", "path": "/var/syncthing/data/memex"}))
PY'
cd /home/nam/.dotfiles/aspects/server && mise run converge
ssh root@homelab 'python3 - <<"PY"
import json, urllib.request, xml.etree.ElementTree as ET
key = ET.parse("/root/.config/syncthing/config.xml").getroot().find("gui/apikey").text
req = urllib.request.Request("http://127.0.0.1:8384/rest/config", headers={"X-API-Key": key})
with urllib.request.urlopen(req) as res:
    cfg = json.load(res)
ids = [d.get("deviceID") for d in cfg.get("devices", [])]
folders = [f.get("id") for f in cfg.get("folders", [])]
assert "ABCDEF-GHIJKLMNOP" in ids, ids
assert "spec-memex" in folders, folders
opts = cfg["options"]
assert opts["globalAnnounceEnabled"] is False
assert opts["localAnnounceEnabled"] is False
assert opts["relaysEnabled"] is False
assert opts["natEnabled"] is False
print("kept device, folder, and hub policy")
PY'
```

Adjust the PUT bodies to the schema the pinned version's `GET /rest/config` returns. The device id must be a real 56-character Syncthing id; generate one with `syncthing --device-id` in a throwaway home if `ABCDEF-GHIJKLMNOP` is rejected. Delete that device and folder in the GUI after the check.

Review:

- Diff does not touch `aspects/dropbox/`, laptop env, or `/srv`.
- Compose publish lines use `127.0.0.1` for 8384 and `${DNS_SERVER_IP}` for 22000.
- Entrypoint does not write a full `config.xml` over an existing one.
- Corefile gained one hosts line.
- Firewall change, if any, is limited to the Tailscale interface.

## Test Strategy

No new unit-test target. Proof is `mise run health`, the `ss` and curl checks, and the second-converge API script. Run them on homelab. They are not part of laptop CI.

## Documentation Strategy

Write `aspects/server/aspects/syncthing/CONTEXT.md` in the same change as the aspect. Update the server and dns CONTEXT files in that change. Do not generate a spec review page into the repo.

## Skills to use

- `development-guidelines` — while implementing the aspect.
- `technical-writing` — CONTEXT.md files.
- `code` — when turning this plan into the files.

## Risks & Mitigations

- CLI flag names differ on the pinned version — read `syncthing cli config --help` before writing the setters.
- `generate` on an existing config resets listen addresses — the one-shot child sets them again after serve is up, and the second-converge check asserts them.
- UFW drops tailnet traffic to 22000 — interface-scoped allow, recorded in CONTEXT.md.
- Docker cannot bind an address that tailscaled has not assigned — container stays down; it does not open 22000 on the LAN address.
- API PUT schema rejects the sample device — use a generated device id and the JSON from `GET /rest/config`.

## Future Work

Parked on the story: Android pairing, household tailnet ACLs, restic, seeding memex, renaming `~/Dropbox`, dissolving `aspects/dropbox`.

## Open Questions

None. Round 2 closed with no comments.
