# Keep Debian Paths for the Samba Share

- **Status:** proposed
- **Decision owner:** nam (repo operator)
- **Accepted or rejected by/date:**
- **Evidence date:** 2026-11-03
- **Scope and expected lifetime:** one standalone `smbd` on the Pi homelab, for as long as that share exists. Laptop mise is `2026.10.7` (2026-10-09).
- **Confidence:** medium. The path recommendation follows current Samba, AppArmor, and mise docs. The Pi’s Debian release and its loaded AppArmor profile were not inspected.

This proposal compares the staged plan, the working-tree plan in `docs/plans/2026-11-01-samba-homelab-aspect.md` as it stood on 2026-11-03, and Debian’s packaged Samba layout. That plan was revised the same day to the recommendation below and is **proposed**. This file does not authorize implementation.

## Job and outcomes

Serve one authenticated SMB share from the homelab Pi. The laptop reaches it on the Tailscale address after `mise run converge`. The SMB password stays out of git. User `samba` can read and write the share and cannot traverse `/root`.

Both drafts already agree on the host `smbd` daemon, `/etc/samba/smb.conf`, SMB2, no guest, no printers, and no Active Directory. The open choice is where the bytes and the daemon databases live, and how much AppArmor and systemd glue that choice requires.

## Hard constraints and non-goals

| Constraint | Hard or preferred | Evidence / owner |
|---|---|---|
| One writable share, user `samba` only | Hard in the working tree | Working-tree decision table. Group `homelab` is the container-data group in `aspects/server/CONTEXT.md`. |
| No execute for `samba` on `/root`, `/root/.local`, or `/root/.local/share` | Hard in both drafts | Both non-negotiable lists |
| Listen on `127.0.0.1` and `DNS_SERVER_IP` only | Hard in the working tree | `smb.conf(5)` requires `127.0.0.1` in `interfaces` when `bind interfaces only = yes`, or `smbpasswd` misses localhost |
| TCP 445 allowed on `tailscale0` only | Hard in the working tree | Parent firewall is default deny. mise firewall `interface` works on UFW, which this host installs. |
| Password and `passdb.tdb` stay out of git and out of converge | Hard in both drafts | Both plans |
| `nmbd` stays masked across package upgrades | Preferred, cheap | mise `[bootstrap.services]` supports `masked = true` on system units |
| Share bytes live under `$XDG_DATA_HOME` | Preferred by `aspects/server/CONTEXT.md` for aspect state | The same page forbids `/srv/square`, `/etc/homelab`, and `/opt/homelab`. It does not forbid FHS `/srv`. |
| No second copy of the share | Decided in the working tree | Disk loss takes the files wherever they sit |
| Domain controller, printers, SMB1, guest, macOS `fruit`, Immich export | Non-goals this pass | Both plans |

## Local capabilities inspected

- Existing repository capability: `aspects/server` bootstrap, XDG quartet in `[vars]`, group `homelab`, UFW rules in `[bootstrap.linux.firewall]`, sibling aspects loaded from `.mise/conf.d/`. Compose services keep data under `/root` because Docker mounts that path as root. `smbd` drops to user `samba` and then walks `path`. Those are different access models. No aspect declares `[bootstrap.users]` yet. Installed mise `2026.10.7` has `mise bootstrap accounts`.
- Standard library / open standard: SMB2; FHS `/srv` for data this host serves; Debian’s packaged directories `etc/samba`, `var/lib/samba`, `var/lib/samba/private`, `var/cache/samba`, `var/log/samba` (`samba-common.dirs` in Debian samba `2:4.22.8+dfsg-0+deb13u1`).
- Framework, runtime, platform, or OS primitive: apt `samba`, systemd `smbd`/`nmbd`, UFW, Debian’s `update-apparmor-samba-profile` as `ExecStartPre`.
- Existing supported dependency/tool: mise bootstrap accounts, packages, files, services, and firewall. Firewall rules merge by name. The most local value of each top-level firewall key wins. Accounts run before files. Services run after files and before the firewall. A system unit that does not exist yet is accepted only when the same run writes its unit file and that file `notify`s the unit.

## Candidates

| Candidate | Class | Exact version/tier | Current evidence | Hard-gate result | Disposition and reason |
|---|---|---|---|---|---|
| Debian packaged directories, share at `/srv/samba/homelab` | Platform primitive, with homelab policy from the working tree | Debian samba `2:4.22.8+dfsg-0+deb13u1` dirs file, dated from the sources listing on 2026-11-03. Pi package not installed. | `samba-common.dirs`; AppArmor upstream `usr.sbin.smbd` allows `/var/lib/samba/**` and `/var/cache/samba/**`; `smb.conf(5)` interfaces | Pass | **Select.** Daemon databases stay where the package and the profile already allow them. |
| Working tree: all Samba state under `/root/.local`, bind export, custom AppArmor reload | Adapt Debian until the package’s paths are gone | Same Samba package, plus files the plan would add | Same sources. `@{HOMEDIRS}/**` in that profile is `lrwk` only. | Pass with mitigation | Reject. The mitigation is a local AppArmor file and a replacement `ExecReload`. That is ownership the packaged paths do not need. |
| Staged plan: same bind, `force group = homelab`, parent hooks, TCP 445 on every interface | Adapt, with a weaker network and permission boundary | Same | mise firewall docs; `CONTEXT.md` on group `homelab` | Fail | Reject. `interface` is omitted, so a bad `interfaces` line exposes 445 on every NIC. `force group` hands new files to the container-data group. Parent `post-packages` / `post-tools` are shared with every other aspect. |
| Bind only the share directory; leave private, state, cache, and logs packaged | Adapt, smaller than the working tree | Same | Mount units are new units, so the mount file must `notify` the mount unit or mise will not accept it | Pass | Fallback if share bytes must appear under `$XDG_DATA_HOME` before a backup job exists. |
| Symlink `/srv/samba/homelab` to the XDG directory, or `+x` on `/root` | OS primitive used the wrong way | — | POSIX path walk checks every directory after a symlink. Both drafts forbid execute on `/root`. | Fail | Reject. |

A container was not taken to a finalist. Both drafts already note that a container still needs a host user, a passdb, and a bind address. mise’s firewall docs also say Docker-published ports do not pass through these host rules.

## Evidence ledger

| Candidate | Observation date | Primary source | Finding | Requirement/risk | Uncertainty |
|---|---|---|---|---|---|
| `interfaces` | 2026-11-03 | [smb.conf(5)](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html) | An entry may be an interface name or an IP address. With `bind interfaces only = yes`, `smbpasswd` connects to `127.0.0.1` unless that address is listed. | Working tree’s `127.0.0.1` plus `DNS_SERVER_IP` matches the man page. `lo` also selects every address on loopback, including `::1` when IPv6 is up. | The man page does not say `SIGHUP` rebinds sockets. An old Samba article says interface changes need a restart. Treat `on_change = "reload"` as unverified for listen-address edits. |
| AppArmor profile | 2026-11-03 | [upstream `usr.sbin.smbd`](https://gitlab.com/apparmor/apparmor/-/raw/master/profiles/apparmor.d/usr.sbin.smbd) | Visible rules grant `/var/lib/samba/** rwk` and `/var/cache/samba/** rwk`. `@{HOMEDIRS}/**` is `lrwk` only. Share paths are added by `include if exists` of the generated snippet. | Relocating `private dir` under `/root` needs a local rule. A `path = /srv/samba/homelab` is the generated snippet’s job, on start. | Include lines were empty in the fetched render. `/var/log/samba` was not visible. Debian’s stock logs use that directory, so the packaged profile is expected to allow it through an include. The Pi profile was not read. |
| Share snippet | 2026-11-03 | [Debian `update-apparmor-samba-profile`](https://sources.debian.org/src/samba/2%3A4.9.5%2Bdfsg-5%2Bdeb10u3/debian/update-apparmor-samba-profile/) (script body; package vintage is older than Trixie) | The script writes `/etc/apparmor.d/samba/smbd-shares` from `path =` lines and reloads the profile when AppArmor is loaded. It exits 0 when AppArmor is absent. | `ExecStartPre` covers the share path on start. A custom `ExecReload` is extra unless `path` changes while `smbd` is already running. | Confirm the Trixie script still uses that path before relying on it. The plan’s reload script matches the grep this older script uses. |
| Packaged directories | 2026-11-03 | [samba-common.dirs](https://sources.debian.org/src/samba/2%3A4.22.8%2Bdfsg-0%2Bdeb13u1/debian/samba-common.dirs) for `2:4.22.8+dfsg-0+deb13u1` | The package creates `/var/lib/samba`, `/var/lib/samba/private`, `/var/cache/samba`, and `/var/log/samba`. | Those paths already satisfy mode `0700` for `private` if the package’s postinst does; this listing does not show modes. | Directory modes on the Pi are unverified. Health can stat them. |
| `samba-ad-dc` Recommends | 2026-11-03 | [Debian samba changelog via Launchpad](https://launchpad.net/debian/+source/samba/+changelog) | `2:4.21.1+dfsg-2` added `Recommends: samba-ad-dc` on `samba`. `2:4.23.0+dfsg-1` stopped recommending it. Bookworm’s control file recommends `samba-ad-provision` instead. | A hold is aimed at Trixie (4.22). It does not suppress Bookworm’s `samba-ad-provision`. Sid no longer needs the hold. | `packages.debian.org/trixie/samba` did not return the control file on this fetch. The Pi release is not in the repo. |
| nmbd mask on upgrade | 2026-11-03 | Same changelog | `2:4.17` masked `nmbd` when `disable netbios = yes`. Sid’s `2:4.23` changelog removes the pre-Bookworm postinst hunk that rewrote masks, and stops enabling `nmbd` by default. | Masking from bootstrap is still the setting that survives an older postinst. It is one service entry. | Trixie `samba.postinst` was not opened. |
| mise accounts, firewall, services | 2026-11-03 | [accounts](https://mise.jdx.dev/bootstrap/accounts.html), [firewall](https://mise.jdx.dev/bootstrap/firewall.html), [services](https://mise.jdx.dev/bootstrap/services.html), and `mise bootstrap --help` on 2026.10.7 | Accounts run first. Firewall rules merge by name; top-level keys use the most local value. `interface` is UFW-capable. `masked` and `on_change = "reload"` exist. A new unit file must `notify` its unit. Order is files, then services, then firewall. | Working-tree account and firewall placement match the docs. A bind-mount unit without `notify` does not. | Docs site may be ahead of 2026.10.7. The installed help lists `accounts` and the service keys match the page fetched today. |
| XDG convention | 2026-11-03 | `aspects/server/CONTEXT.md` | Compose data lives under the XDG quartet. The rejected paths are `/srv/square`, `/etc/homelab`, and `/opt/homelab`. | `/srv/samba/homelab` is a new `/srv` path. It is not the old square tree. | Whether nam wants `find /root/.local/share` to be the only data tree is a preference, not a documented ban on `/srv/<service>`. |

## Qualitative trade-offs

| Dimension | Working tree | Staged plan | Debian paths |
|---|---|---|---|
| Functional fit | Meets the share, the closed `/root`, and the Tailscale listener. | Meets the share and the closed `/root`. New files are group `homelab`. Port 445 is open on every interface that UFW guards. | Meets the same share and listener goals. `path` is the directory `samba` can already traverse: `/`, `/srv`, `/srv/samba`, `/srv/samba/homelab`. |
| Architecture fit | Moves private, state, cache, and logs off the paths the package and the profile know. Then adds a local profile and a reload script so `smbd` can open them. | Same relocation, plus edits to the parent hooks every aspect shares. | `smb.conf` sets the share, the listen addresses, and the protocol floor. Daemon directories stay unnamed. |
| Security and privacy | Owner `samba:samba` and mode `0700` match a single SMB user. Firewall interface is `tailscale0`. | `force group = homelab` and mode `2770` let every `homelab` member read and write new files. Firewall has no interface. | Same owner, mode, and firewall as the working tree. `private` stays root-owned on the packaged path. |
| Operations | Custom `ExecReload` must keep working across Debian’s `update-apparmor-samba-profile`. A parser failure skips `SIGHUP`, and the plan already says `smbd` rereads `smb.conf` on its own timer. | `post-tools` runs `testparm` before reload. The timer still applies the file on disk, so the gate delays a bad config rather than stopping it. | Packaged `ExecStartPre` refreshes the share snippet on start. `on_change = "reload"` stays the packaged `SIGHUP`. |
| Total ownership | Mount unit, drop-in, reload script, AppArmor local file, four relocated trees, hold, debconf hook. | Mount unit, drop-in, parent hook scripts, conditional AppArmor. | Account, package, hold, `smb.conf`, two directories, `smbd`/`nmbd` service entries, one firewall rule, DNS name, password task. |
| Lock-in and exit | Leaving the design means moving `passdb.tdb` back to `/var/lib/samba/private` or teaching the next host the same AppArmor rules. | Same passdb move, plus unpicking parent hooks. | Remove the aspect, the firewall rule (`state = "absent"`), and `/srv/samba`. The package’s directories remain the package’s. |
| Whole-system mechanism | The XDG move adds files, a parser invocation, and a second path for the same bytes. | Same bind, and the parent hooks are a second way to create users beside `[bootstrap.users]`. | One directory tree for the bytes. No mount ordering. |

## Decision

- **Outcome:** adapt
- **Recommendation:** Use Debian’s directories. Put the share at `/srv/samba/homelab`, owner `samba:samba`, mode `0700`. Leave `private dir`, `state directory`, `cache directory`, and `log file` unset. Keep the working tree’s homelab policy: `[bootstrap.users]` / `[bootstrap.groups]` and `"apt:samba"` in the Samba aspect, hold `samba-ad-dc`, `interfaces = 127.0.0.1` and `DNS_SERVER_IP`, firewall rule `smb` on `tailscale0` only, `nmbd` stopped, disabled, and masked, create mask `0600`, directory mask `0700`, no `force group`, and `samba:passwd` outside converge.
- **Why this wins:** The working tree is the better of the two drafts on permissions, firewall scope, accounts, and `nmbd`. Its extra files exist to store root-read databases under `/root/.local`. The AppArmor profile already allows `/var/lib/samba/**` and `/var/cache/samba/**`, and it does not grant read/write on `@{HOMEDIRS}/**`. The packaged paths remove the local profile and the replacement reload script. The staged draft loses on the firewall and on `force group`.
- **Strongest counterargument:** `CONTEXT.md` points aspect data at the XDG quartet. `/srv/samba/homelab` is a second tree, and a later backup that only copies `/root/.local/share` will miss the share and the passdb.
- **What bespoke glue or ownership remains:** The aspect still owns `smb.conf`, the system user, the `samba-ad-dc` hold, the Tailscale firewall rule, the `nmbd` mask, the DNS name, and the password task. It does not own an AppArmor profile or an `ExecReload` script.
- **What evidence would change the decision:** A backup design that refuses to name `/srv/samba` and `/var/lib/samba/private`. Then use the fallback below, not the full working tree. Or an AppArmor denial for `/var/lib/samba` or `/srv/samba/homelab` after `ExecStartPre` has run. Then add the narrow local rule the denial names.

Fallback, if the share bytes have to live under `$XDG_DATA_HOME` now: bind-mount only `/root/.local/share/samba/shares/homelab` onto `/srv/samba/homelab`. Leave the four daemon directories packaged. The mount file `notify`s `srv-samba-homelab.mount`. The `smbd` drop-in is `After=` and `Requires=` that mount, and it does not replace `ExecReload`.

## Proof of fit

- **Question and representative workload:** After one converge, does `smbd` serve `/srv/samba/homelab` as user `samba` with listeners only on `127.0.0.1:445` and `DNS_SERVER_IP:445`, without a local AppArmor file?
- **Success/failure boundary:** Success is `testparm` exit 0, `findmnt` showing no bind on that path, `sudo -u samba test -x /root` exit 1, `ss` showing only those two listeners, and `smbclient //files.homelab.xyz/homelab --user samba --command 'ls'` after `samba:passwd`. Failure is an AppArmor denial for `/var/lib/samba` or `/srv/samba/homelab`, or a listener on another address.
- **Execution authority:** Not granted. This proposal does not install packages or apply bootstrap.
- **Exact artifact/version and checksum/signature/provenance:** Whatever `apt:samba` resolves to on the Pi at converge time. Record `dpkg-query -W samba apparmor` in the converge notes.
- **Least-privilege sandbox:** The homelab Pi is the only host that can answer the AppArmor question. Do not point a test install at the live passdb once one exists.
- **Network, mounts, credentials, host services, and other authorized exceptions:** None for this proposal.
- **Timebox:** One converge and the health checks already in the plan.
- **Result or unresolved obligation:** Unresolved until that converge.

## Ownership and implementation route

- **Upgrade/security/incident owner:** nam
- **Supported version/range or service tier:** Debian `samba` at `"latest"`, with `samba-ad-dc` held. Re-check the Recommends line when the Pi moves to a release whose changelog matches `2:4.23.0` or newer; the hold can go once `samba` no longer recommends `samba-ad-dc`.
- **Dependency boundary:** One apt package and its existing dependencies. No new AppArmor package requirement. If AppArmor is already enforcing, use Debian’s `ExecStartPre` rather than a repo-owned parser invocation.
- **Rollout and recovery:** First converge creates the user, the share directory, and the daemon. `samba:passwd` runs only after `testparm` shows the private directory still at the packaged path. Removing the aspect later does not delete `/srv/samba/homelab` unless a directory entry says so.
- **Implementation skills/plan:** Revise `docs/plans/2026-11-01-samba-homelab-aspect.md` to this layout, then `manage-aspects` and `tdd` only after this proposal is accepted. `planning` if that revision is still more than one slice.

## Exit and re-evaluation

- **Data/configuration export and replacement path:** Copy `/srv/samba/homelab`. Recreate the SMB user with `samba:passwd` on the next host, or copy `/var/lib/samba/private` with root permissions if the hash has to move. `smb.conf` lives in the aspect.
- **Removal/migration cost:** Delete the aspect, set the firewall rule `state = "absent"`, and remove `/srv/samba` when the files have a new home. There is no mount unit to unwind.
- **Re-evaluate when:** the Pi changes Debian release; AppArmor denies a packaged path; `samba` stops recommending `samba-ad-dc`; a backup job is specified; another local user needs these bytes; or Tailscale’s address stops being a stable bind target.

## References

- Samba `smb.conf(5)`, current manual, fetched 2026-11-03: https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
- AppArmor `profiles/apparmor.d/usr.sbin.smbd`, master, fetched 2026-11-03: https://gitlab.com/apparmor/apparmor/-/raw/master/profiles/apparmor.d/usr.sbin.smbd
- Debian `samba-common.dirs` at `2:4.22.8+dfsg-0+deb13u1`: https://sources.debian.org/src/samba/2%3A4.22.8%2Bdfsg-0%2Bdeb13u1/debian/samba-common.dirs
- Debian `update-apparmor-samba-profile` (older source revision, script inspected 2026-11-03): https://sources.debian.org/src/samba/2%3A4.9.5%2Bdfsg-5%2Bdeb10u3/debian/update-apparmor-samba-profile/
- Debian samba changelog, including the `samba-ad-dc` Recommends add and removal: https://launchpad.net/debian/+source/samba/+changelog
- Bookworm `samba` control, Recommends `samba-ad-provision`: https://tracker.debian.org/media/packages/s/samba/control-24.17.12dfsg-0deb12u2
- mise 2026 docs, fetched 2026-11-03: https://mise.jdx.dev/bootstrap/accounts.html , https://mise.jdx.dev/bootstrap/firewall.html , https://mise.jdx.dev/bootstrap/services.html
- Local: `aspects/server/CONTEXT.md`, `aspects/server/mise.toml`, `docs/plans/2026-11-01-samba-homelab-aspect.md`
