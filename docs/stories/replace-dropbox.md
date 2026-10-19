# Specification map: replace Dropbox

story: create a new aspects/server/aspects/ that helps me replace dropbox

rules:
  - rule: Story artifact lives under docs/stories
    examples:
      - This file is the home for rules, examples, parked questions, and acceptance criteria until the map stabilises. The deploy unit is aspects/server/aspects/syncthing/ and gets a CONTEXT.md later.

  - rule: This story is only the homelab Syncthing hub
    examples:
      - `mise run converge` from aspects/server brings up Syncthing on homelab (the Pi). It does not edit 10-env.fish, does not move ~/Dropbox to ~/Sync, and does not remove aspects/dropbox.
      - Android pairing, household tailnet ACLs, restic, and seeding memex are later stories. This aspect does not pair a phone or copy ~/Dropbox/memex onto the Pi.

  - rule: The hub stores synced files under $XDG_DATA_HOME/syncthing
    examples:
      - After converge on homelab, synced file bytes live in /root/.local/share/syncthing (XDG_DATA_HOME from /etc/environment), directory group homelab, mode 2770. Syncthing's own config lives in /root/.config/syncthing. Nothing is created at /srv/sync/nam.

  - rule: The unit follows the current homelab aspect structure
    examples:
      - The git unit is aspects/server/aspects/syncthing/. Bootstrap starts it with Docker Compose the same way anki starts: compose project under /root/.config/syncthing/compose, an env file, and a dependency on docker. It is not a host systemd unit and it does not use /srv.

  - rule: The GUI is HTTPS on the tailnet; device sync uses the Tailscale address
    examples:
      - From a machine on the tailnet, https://sync.homelab.xyz opens the Syncthing GUI. Caddy has a sync.homelab.xyz site (tls internal) that reverse-proxies to the GUI on 127.0.0.1. The dns aspect Corefile hosts block gains a line for sync.homelab.xyz beside anki and budget, so getent hosts sync.homelab.xyz returns the Pi's Tailscale address (100.121.171.33 today).
      - Another Syncthing device syncs to 100.121.171.33 port 22000. http://100.121.171.33:8384 does not serve the GUI. A machine on the house LAN that is not on the tailnet cannot open the GUI or connect to port 22000.

  - rule: First converge leaves the folder list empty
    examples:
      - After converge, /root/.local/share/syncthing exists and contains no user folders. https://sync.homelab.xyz shows an empty folder list. Syncthing's usual first-run folder named default, aimed at ~/Sync, is not created. There is no memex, backup, data, opt, or inbox directory, and ~/Dropbox/memex is not copied.

  - rule: The hub does not use public discovery or relays
    examples:
      - After converge, global discovery, local announce, and relays are off. A phone on LTE that is not joined to the tailnet does not connect, even when it has the hub device ID. A device on the tailnet connects only when it is given the hub device ID and tcp://100.121.171.33:22000.

  - rule: Port 22000 listens only on the Tailscale address
    examples:
      - After converge, TCP and UDP 22000 are published on 100.121.171.33, the value of DNS_SERVER_IP in the dns aspect. The Pi's house LAN address has no listener on 22000. The GUI listens on 127.0.0.1:8384 only, and http://100.121.171.33:8384 does not serve it.
      - A later converge after DNS_SERVER_IP changes republishes 22000 on the new address and drops the old one. It does not add 0.0.0.0:22000. While tailscaled is down, 22000 is not opened on the LAN address as a fallback.

  - rule: The GUI requires the username and password from the syncthing aspect
    examples:
      - aspects/server/aspects/syncthing/mise.toml sets the GUI username and password the same way anki sets SYNC_USER1 = "user:pass", and bootstrap templates them into /root/.config/syncthing/compose.env. Opening https://sync.homelab.xyz with no credentials, or with user / wrong, does not show the folder list. Opening it with the username and password from that file shows the empty folder list.

  - rule: A later converge keeps devices and folders, and reapplies hub policy
    examples:
      - In the GUI you add device ABCDEF-GHIJKLM and a folder named memex at /root/.local/share/syncthing/memex. A second `mise run converge` still lists ABCDEF-GHIJKLM and memex. Global discovery, local announce, and relays stay off. TCP and UDP 22000 stay published only on the current DNS_SERVER_IP.
      - You change the GUI password in the browser and turn global discovery on. The next converge sets the password back to the value in aspects/server/aspects/syncthing/mise.toml and turns global discovery off. Device ABCDEF-GHIJKLM and folder memex are still listed.

questions:

acceptance criteria:
  - `mise run converge` from aspects/server starts Syncthing via aspects/server/aspects/syncthing/. It does not edit 10-env.fish, move ~/Dropbox, remove aspects/dropbox, pair a phone, or copy ~/Dropbox/memex.
  - Synced bytes are at /root/.local/share/syncthing, group homelab, mode 2770. Syncthing config is at /root/.config/syncthing. /srv/sync/nam does not exist.
  - The process is the Docker Compose project at /root/.config/syncthing/compose, with /root/.config/syncthing/compose.env. It is not a host systemd unit.
  - From the tailnet, https://sync.homelab.xyz asks for the username and password from aspects/server/aspects/syncthing/mise.toml. The right pair shows an empty folder list. No credentials, or user / wrong, does not. getent hosts sync.homelab.xyz returns DNS_SERVER_IP. http://100.121.171.33:8384 does not serve the GUI.
  - The data directory has no memex, backup, data, opt, inbox, or default folder, and the GUI folder list is empty.
  - Global discovery, local announce, and relays are off. A phone on LTE that is not on the tailnet does not connect, even with the hub device ID.
  - TCP and UDP 22000 are published only on DNS_SERVER_IP. The house LAN address has no listener on 22000. After DNS_SERVER_IP changes, the next converge publishes the new address and drops the old one. While tailscaled is down, 22000 is not opened on the LAN address.
  - After a device and a folder are added in the GUI, a second converge still lists both. A GUI password change and a GUI discovery change are overwritten by the values from the aspect.

candidate terms:
  - homelab aspect: a git unit under aspects/server/aspects/<name>/, deployed by mise bootstrap remote homelab
  - hub: the always-on Pi copy that other devices sync with
  - sync.homelab.xyz: the tailnet-only HTTPS name for the Syncthing GUI
  - hub config: Syncthing's own record of devices and folders, separate from the username and password in mise.toml
  - hub policy: the settings a later converge writes again — GUI password, global discovery, local announce, relays, and the 22000 listen address

## Story split

### Parent

After converge, the operator can log into an empty Syncthing hub on homelab. Later devices join only on the tailnet. A later converge keeps devices and folders added in the GUI and writes hub policy again.

### Recommended first slice

One story: the whole hub, as specified in the rules and acceptance criteria above.

Why this first: the ten rules are policies of one converge. A hub left up while public relays are still on is not safe to leave running, and a second converge that drops a device added during the first check undoes that check.

### Split candidates

| Slice | Value | Includes | Defers | Acceptance examples | Release constraint |
|---|---|---|---|---|---|
| The whole hub | An always-on empty copy you can log into, ready for a later device | Every rule in this map | Android pairing, household tailnet ACLs, restic, seeding memex, renaming ~/Dropbox, dissolving aspects/dropbox | The acceptance criteria above | Shippable on the tailnet by `mise run converge` from aspects/server |

### Parking lot

- Android pairing
- Household tailnet ACLs
- Restic backups
- Seeding memex onto the hub
- Renaming ~/Dropbox to ~/Sync
- Dissolving aspects/dropbox

### Warnings

The rule count is ten. It stays one story because those rules are one capability's policies. Compose, Caddy, and the port bind are tasks inside the story.

### Next step

Round 2 (2026-10-17) returned no comments. No new rules, no changed examples, no new questions. Implementation plan: `docs/plans/replace-dropbox-hub.md`. Code waits until that plan is approved.
