# Add Samba homelab aspect

- **Status:** proposed
- **Decision owner:** nam (repo operator)
- **Scope:** `aspects/server` — one authenticated SMB share on the Pi homelab (`SERVER`, default `homelab`)
- **Tier:** comprehensive — authenticated network service and a firewall rule
- **Related:** `docs/plans/2026-11-03-samba-layout-decision.md`, `aspects/server/CONTEXT.md`, `aspects/server/mise.toml`, `aspects/server/aspects/dns/mise.toml`

## Goal

Serve one authenticated SMB share from the homelab Pi, reachable only on the Tailscale address, through `mise run converge`.

The share is `/srv/samba/homelab`. That directory holds the bytes. Only the SMB user `samba` can read or write them. TCP 445 is allowed on `tailscale0` only.

## Context & Decisions

The active homelab unit is `aspects/server/aspects/<name>/`, loaded by a symlink in `aspects/server/.mise/conf.d/`. Deploy is bootstrap-only from `aspects/server/mise.toml`. The Pi uses apt and systemd. The [Arch Samba wiki](https://wiki.archlinux.org/title/Samba) is the configuration reference. Unit and package names follow Debian.

Samba runs as the host `smbd` daemon. A container would still need the host user, the passdb, and the interface binding.

`path` in `smb.conf` is the directory `smbd` opens after it drops from root to the Unix user `samba`. That user must be able to traverse every directory from `/` down to `path`. `/root` is mode `0700`. `/srv/samba/homelab` is a path `samba` can walk: `/`, `/srv`, `/srv/samba`, `/srv/samba/homelab`.

Debian builds this Samba with `--with-privatedir=/var/lib/samba/private`, `--with-statedir=/var/lib/samba`, `--with-cachedir=/var/cache/samba`, `--with-piddir=/run/samba`, and `--with-lockdir=/run/samba` (`debian/rules` for `2:4.22.8+dfsg-0+deb13u1`). The package creates `/var/lib/samba`, `/var/lib/samba/private`, `/var/cache/samba`, and `/var/log/samba`. There is no `/var/lib/samba/state`. Persistent databases sit in `/var/lib/samba`. The upstream `smbd` AppArmor profile allows `/var/lib/samba/**` and `/var/cache/samba/**`. `smb.conf` leaves `private dir`, `state directory`, `cache directory`, and `log file` unset, so Samba uses those build paths. The aspect does not declare the packaged directories or `/run/samba`. The `smbd` unit creates `/run/samba` at start.

| Role | Path | Owner | Mode | Who opens it |
|---|---|---|---|---|
| State and persistent databases | `/var/lib/samba` | package | package | `smbd` as root |
| Passdb and secrets | `/var/lib/samba/private` | package | package | `smbd` as root |
| Cache | `/var/cache/samba` | package | package | `smbd` as root |
| Logs | `/var/log/samba` | package | package | `smbd` as root |
| Pid, locks, ncalrpc | `/run/samba` | packaged unit | packaged unit | packaged `smbd` unit |
| Export parent | `/srv/samba` | `root:root` | `0755` | user `samba` traverses it |
| Share | `/srv/samba/homelab` | `samba:samba` | `0700` | user `samba` |

Printing stays disabled, so there is no spool directory. Syncthing keeps writing `$XDG_DATA_HOME/syncthing` as uid `1000` and group `homelab`. This share stays user `samba` only.

| Decision | Choice | Why |
|---|---|---|
| Scope | One writable share, `homelab` | First pass needs one verifiable share |
| Readers and writers | SMB user `samba` only | Group `homelab` is the container-data convention and has no consumer for these bytes |
| Daemon config | `/etc/samba/smb.conf` | Daemon config stays under `/etc`, as Caddy does |
| Share | `/srv/samba/homelab`, owner `samba:samba`, mode `0700` | Traversable without execute on `/root` |
| Daemon directories | Packaged paths, parameters unset in `smb.conf` | The package and the AppArmor profile already allow them |
| New files | create mask `0600`, directory mask `0700`, no `force group` | Created files stay owner-only |
| Account | `[bootstrap.users.samba]` and `[bootstrap.groups.samba]` in the Samba aspect | Accounts run before directories, so the share can be owned by `samba` |
| Auth | Samba passdb, no guest, password set by `samba:passwd` | The password stays out of git and out of converge |
| Package | `"apt:samba" = "latest"` in the Samba aspect; hold `samba-ad-dc` | This pass has no domain controller |
| Network | `bind interfaces only`, `127.0.0.1` and `DNS_SERVER_IP`, SMB2 minimum, NetBIOS off | The listener set is those two addresses |
| Firewall | Rule `smb`, TCP 445, `interface = "tailscale0"`, in the Samba aspect | Rules merge by name; policy keys stay in the parent |
| `nmbd` | stopped, disabled, and masked | A package upgrade can enable a unit that is only disabled |
| Config apply | `notify = ["smbd"]`, `on_change = "reload"` | The services step sends the packaged `SIGHUP` before the firewall step opens 445 |
| Discovery | DNS name `files.homelab.xyz` | The laptop check uses `//files.homelab.xyz/homelab` |
| Copies | None | A lost Pi disk takes the share with it |

`DNS_SERVER_IP` is `100.121.171.33` in `aspects/server/aspects/dns/mise.toml`. `DNS_DOMAIN` is `homelab.xyz` there. Sibling aspects see those vars in bootstrap templates. Syncthing already templates `vars.DNS_SERVER_IP`.

Immich, when it exists, gets its own data directory. Exporting that directory over SMB is a later slice.

## Current State

- No Samba package, unit, firewall rule, or share exists. Incoming firewall policy is deny in `aspects/server/mise.toml`.
- Open ports are 22, 80, 443, 53, 6443, mosh, and 23231. SMB is absent.
- Private names live in `aspects/server/aspects/dns/Corefile`.
- `tasks.health` checks current services and paths only.
- Group `homelab` exists. Root is added to it from `post-packages`. Mise cannot manage the `root` user.
- Every apt package today is declared in `aspects/server/mise.toml`. Package keys merge across config files, so the Samba aspect can add `"apt:samba"`.
- Laptop tasks (`tailscale:join`, `health`) live in `aspects/server/mise.toml`.

## Non-Negotiables

- `path` for the share is `/srv/samba/homelab`. It is not a path under `/root`.
- User `samba` receives no execute permission on `/root`, `/root/.local`, or `/root/.local/share`.
- Bind `smbd` to `127.0.0.1` and `DNS_SERVER_IP` only. `interfaces` lists those two addresses, not the name `lo`.
- `nmbd` is stopped, disabled, and masked. Health passes only when `systemctl is-enabled nmbd` prints `masked`.
- Set `server min protocol = SMB2`, `map to guest = never`, and `guest ok = no`.
- Keep the Samba password out of the repository. Converge preserves `passdb.tdb` and `secrets.tdb` by never writing those files.
- Leave `private dir`, `state directory`, `cache directory`, and `log file` unset. Bootstrap creates `/srv/samba` and `/srv/samba/homelab` only. The share is mode `0700` and owned by `samba:samba`.
- Leave Syncthing data, Docker volumes, printers, Active Directory, SMB1, guest access, and macOS metadata out of this pass.
- The firewall rule lives in the Samba aspect under the name `smb`. The aspect does not set `backend`, `default_incoming`, or `exclusive`. Mise merges firewall rules by name, and the most local value of each top-level firewall key wins.
- Leave the parent `post-packages` and `post-tools` hooks unchanged.

## Technical Approach

Create `aspects/server/aspects/samba/` and symlink `aspects/server/.mise/conf.d/samba` to `../../aspects/samba`.

### Account, package, and Debian prompts

In `aspects/server/aspects/samba/mise.toml`:

```toml
[bootstrap.packages]
"apt:samba" = "latest"

[bootstrap.groups.samba]
system = true

[bootstrap.users.samba]
system = true
group = "samba"
home = "/nonexistent"
shell = "/usr/sbin/nologin"
create_home = false
comment = "Samba share"

[bootstrap.hooks.pre-packages]
run = """
#!/bin/sh
set -eu
printf '%s\n' 'samba-common samba-common/do_debconf boolean false' | debconf-set-selections
apt-mark hold samba-ad-dc
"""
```

Leave `uid` unset. A system account is created with a locked Unix password. The SMB password is separate and is set by `samba:passwd`.

The `pre-packages` hook runs before apt installs `samba`. Debian Trixie `samba` 4.22 recommends `samba-ad-dc`, and `apt-get install -y` installs recommendations. The hold makes apt skip that recommendation. `apt-mark hold` on a package that is not in the archive succeeds, so the same hook is safe on a release without `samba-ad-dc`. Bookworm recommends `samba-ad-provision` instead. This pass does not hold that package.

Debian Trixie `samba-common.postinst` (source `2:4.22.11+dfsg-0+deb13u1`) installs `/usr/share/samba/smb.conf` with `ucf --three-way --debconf-ok`. That source tree has no `do_debconf` template. Bookworm may still honor the debconf key. The Pi’s Debian release is not recorded in this repo. The hook stays. On a ucf-based release, the files step still writes `/etc/samba/smb.conf` after the package install.

### `smb.conf`

`aspects/server/aspects/samba/smb.conf`, deployed to `/etc/samba/smb.conf` with mode `0644`, `template = true`, and `notify = ["smbd"]`:

```ini
[global]
   workgroup = HOMELAB
   server role = standalone server
   security = user
   map to guest = never
   max log size = 1000
   server min protocol = SMB2
   disable netbios = yes
   smb ports = 445
   bind interfaces only = yes
   interfaces = 127.0.0.1 {{ vars.DNS_SERVER_IP }}
   load printers = no
   printing = bsd
   disable spoolss = yes

[homelab]
   path = /srv/samba/homelab
   browseable = yes
   read only = no
   guest ok = no
   valid users = samba
   create mask = 0600
   directory mask = 0700
```

User `samba` is not a member of `homelab`. `passdb backend`, `private dir`, `state directory`, `cache directory`, and `log file` stay at the Debian defaults. `ExecStartPre` in the packaged unit runs `update-apparmor-samba-profile`, which writes `/etc/apparmor.d/samba/smbd-shares` from `path =` lines when AppArmor is loaded and exits 0 when AppArmor is absent.

### Services

```toml
[bootstrap.services.smbd]
state = "running"
enabled = true
on_change = "reload"

[bootstrap.services.nmbd]
state = "stopped"
enabled = false
masked = true
```

A converge that changes `smb.conf` runs `systemctl reload smbd` in the services step, before the firewall step. That reload is the packaged `SIGHUP`. An unchanged file does not reload it. `on_change = "reload"` does not run `systemctl restart`. There is no Samba `post-tools` hook and no `smbd` drop-in.

`smbd` also rereads a changed `smb.conf` on its own within three minutes. That timer is independent of the reload command. An old Samba note says a change to `interfaces` needs a restart before the listen sockets move. The first converge starts `smbd` with the rendered addresses. A later change to `DNS_SERVER_IP` is checked with `ss` after reload, and `smbd` is restarted if the listener set is still the old one.

### Directories

Declare these directories:

| Path | Owner | Mode |
|---|---|---|
| `/srv/samba` | `root:root` | `0755` |
| `/srv/samba/homelab` | `samba:samba` | `0700` |

Bootstrap manages those two directories only. It does not copy or replace `passdb.tdb` or `secrets.tdb`.

### Firewall

In the Samba aspect, one rule and no firewall policy keys:

```toml
[[bootstrap.linux.firewall.rules]]
name = "smb"
port = 445
protocol = "tcp"
interface = "tailscale0"
action = "allow"
```

### DNS, health, and the password task

Add this hosts line to `aspects/server/aspects/dns/Corefile`, beside the existing names:

```
{{ vars.DNS_SERVER_IP }} files.{{ vars.DNS_DOMAIN }}
```

Add `samba:passwd` to `aspects/server/mise.toml`. It is a laptop task, `interactive = true`, and it is not part of `converge`. From `aspects/server`:

```bash
mise run samba:passwd
```

The task SSHes to the Pi and does three things:

1. It exits non-zero unless `testparm -s --parameter-name "private dir"` prints `/var/lib/samba/private`.
2. It exits 0 without prompting when `pdbedit -L` already lists a line starting with `samba:`.
3. Otherwise it runs `ssh -t root@$SERVER smbpasswd -a samba`.

Extend the SSH half of `tasks.health`. A check fails the task when any of these is false:

| Check | Pass |
|---|---|
| `smbd` | `systemctl is-active --quiet smbd` |
| `nmbd` | `systemctl is-enabled nmbd` prints `masked` (that command exits 1) |
| Share | `stat -c %U:%G:%a /srv/samba/homelab` prints `samba:samba:700` |
| Config | `testparm --suppress-prompt` exits 0 |
| Private directory | `testparm -s --parameter-name "private dir"` prints `/var/lib/samba/private` |
| Port 445 | listeners are `127.0.0.1:445` and `DNS_SERVER_IP:445`, and no other address |

`mise run health` has no SMB password, so it does not run `smbclient`. The laptop client check is separate and runs after `samba:passwd`. This aspect does not install `smbclient`. Health also records `stat -c %U:%G:%a /var/lib/samba/private`. The package owns that mode. The first converge is what shows it.

## System Impact

`smbd` serves files as user `samba` through `/srv/samba/homelab`. A converge that changes `smb.conf` reloads `smbd` with the packaged `SIGHUP`. The passdb stays in `/var/lib/samba/private` and survives converge. The share is not copied anywhere. A backup that only copies `/root/.local/share` misses `/srv/samba/homelab` and `/var/lib/samba/private`.

## Implementation Slices

### Slice 1: Host share and daemon

- Add the aspect, symlink, package, hold, debconf hook, user, group, the two directories, `smb.conf`, and the `smbd` and `nmbd` service states.

Verification:

```bash
cd aspects/server
mise run converge
ssh root@$SERVER 'testparm --suppress-prompt'
ssh root@$SERVER 'testparm -s --parameter-name "private dir"'
ssh root@$SERVER 'systemctl is-active smbd'
ssh root@$SERVER 'systemctl is-enabled nmbd; echo nmbd-enabled-exit:$?'
ssh root@$SERVER 'sudo -u samba test -x /root; echo samba-root-exit:$?'
ssh root@$SERVER 'stat -c %U:%G:%a /srv/samba/homelab /var/lib/samba/private'
```

`nmbd-enabled-exit` is `1` and the printed state is `masked`. `samba-root-exit` is `1`. `private dir` prints `/var/lib/samba/private`. The share stat is `samba:samba:700`.

Review:

Confirm `path` is `/srv/samba/homelab`, `interfaces` is `127.0.0.1` and `DNS_SERVER_IP`, the rendered config contains no password, `smb.conf` has no `force group`, and `private dir`, `state directory`, `cache directory`, and `log file` are absent from the file.

### Slice 2: Client reachability

- Add the firewall rule, the Corefile name, `samba:passwd`, the health checks, and the context docs.

Verification:

```bash
cd aspects/server
mise run health
ssh root@$SERVER 'ss -lnt "( sport = :445 )"'
mise run samba:passwd
smbclient //files.homelab.xyz/homelab --user samba --command 'ls'
```

Run `smbclient` from the laptop after the password task. A missing password fails authentication. It does not fall back to guest access.

Review:

Confirm the firewall rule is named `smb`, is limited to `tailscale0`, and is the only SMB port opened. Confirm the parent firewall policy keys are unchanged.

## Test Strategy

Use `testparm` as the configuration check. Use `sudo -u samba test -x /root` to prove `/root` stayed closed. Use `ss` to prove the listener set is exactly `127.0.0.1:445` and `DNS_SERVER_IP:445`. Use `systemctl is-enabled nmbd` to prove the mask. Use `stat` to prove the share is `samba:samba` mode `0700`. After `samba:passwd`, the client check is:

```bash
smbclient //files.homelab.xyz/homelab --user samba --command 'ls'
```

## Documentation Strategy

Add `aspects/server/aspects/samba/CONTEXT.md` with the path table, `mise run samba:passwd`, the `samba-ad-dc` hold, and the verification commands. Register the aspect in the table, prose, routing section, and health description in `aspects/server/CONTEXT.md`.

## Skills to use

- `manage-aspects` — create the aspect and `conf.d` symlink.
- `technical-writing` — write `CONTEXT.md` and the server routing updates.
- `sr-eng-review` — review the final diff, with attention to the firewall, the bind address, and the share path.

## Risks & Mitigations

- Debian enables `nmbd` when `samba` is installed. The `nmbd` service entry masks it on every converge. `disable netbios = yes` makes Debian’s `is-configured nmb` exit 1, so the packaged `ExecCondition` also refuses to start it.
- Debian’s `samba.postinst` unmasks `nmbd` when upgrading from a version older than `2:4.17.4+dfsg-3` if the unit file is a symlink to `/dev/null`. The next converge masks it again.
- Trixie recommends `samba-ad-dc`. The hold keeps it off the host. Bookworm can still install the recommended `samba-ad-provision` package. That package is not the domain-controller service.
- On Trixie, `ucf` can change `/etc/samba/smb.conf` during a package upgrade between converges. The next converge writes the aspect file again. `smbd` rereads a changed file within three minutes.
- A converge that changes `smb.conf` reloads `smbd` without running `testparm` first. `on_change = "reload"` does not restart the process when reload fails. The three-minute reread still applies to the file on disk.
- A change to `interfaces` may leave the old listen sockets in place after `SIGHUP`. `ss` after that converge shows the listener set, and a restart of `smbd` is the follow-up when the set is wrong.
- An AppArmor denial for `/srv/samba/homelab` after `ExecStartPre` has run names the rule still missing. Add that rule then. The aspect does not ship a local profile before a denial exists.
- The share has one copy. Disk loss removes the files. A backup of only `/root/.local/share` misses `/srv/samba/homelab` and `/var/lib/samba/private`.
- Giving this directory to Syncthing would require group `homelab` and two writers on the same files. That stays out of this pass.

## Future Work

- A copy of the share and of `/var/lib/samba/private` that survives Pi disk loss.
- An Immich library in its own directory, with its own SMB export if a client needs it.
- Additional shares or per-user permissions.
- macOS `fruit` metadata support.

## Open Questions

None.
