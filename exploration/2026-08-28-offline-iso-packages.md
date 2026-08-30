# Solution Decision: Offline package set on the custom Arch ISO

- **Status:** proposed
- **Decision owner:** you (personal operator)
- **Accepted or rejected by/date:**
- **Evidence date:** 2026-08-28
- **Scope and expected lifetime:** personal reinstall medium; months between rebuilds; high convenience, low irreversibility (official monthly ISO remains the online fallback)
- **Confidence:** medium — mechanism is documented and used in production by omarchy-iso; this repo’s desktop package list is smaller and official-repo-only, but a full “no downloads” install still has non-pacman edges (mise tools, nerd-fonts zip, live `curl` of `boot.sh`) that were not measured as an ISO

## Job and outcomes

Boot a USB, run this repo’s installer, and finish a usable Sway machine without pacman hitting the network. You chose the Omarchy-shaped scope: not only `archinstall`’s base set, but the desktop packages `install.sh` → `//aspects/aur:packages` would otherwise download.

Observable outcomes:

- Custom ISO built by `bin/arch-install/mkiso.sh` contains every pacman package the live install and first `aur:packages` run need.
- `archinstall` pacstrap and the later `pacman -S` of `aspects/aur/packages` succeed with no mirror.
- Official monthly ISO path stays an online fallback. Age keys stay off the ISO.

## Hard constraints and non-goals

| Constraint | Hard or preferred | Evidence / owner |
|---|---|---|
| No pacman downloads during install | Hard | Your choice 2026-08-28 (full desktop, not archinstall-only) |
| Keep existing installer (configure.sh → archinstall → install.sh), not Omarchy quattro | Hard | `exploration/arch-install.md`: “Do not fork `omarchy-iso`” |
| Official ISO still works without the custom image | Preferred | Same doc; custom ISO is an overlay |
| Do not bake checkout, creds, or age keys | Hard | `exploration/arch-install.md` Custom live ISO |
| Do not extract `airootfs.sfs` as the installed root | Hard | [ArchWiki Offline installation](https://wiki.archlinux.org/title/Offline_installation) warning |
| Air-gapped machine after reboot with USB removed | Non-goal unless you later say so | Would require copying the repo onto the disk or finishing desktop install before reboot |
| Comment-in AUR/`paru` packages | Non-goal this round | Those lines are commented in `aspects/aur/packages` |
| Own a second installer product | Non-goal | Quattro contract rejected |

## Local capabilities inspected

- Existing repository capability: `bin/arch-install/mkiso.sh` copies archiso `releng`, appends `iso/packages.append` (`gum` only) to `packages.x86_64`, overlays `keyboard.sh` / `network.sh` / `iso/start.sh`, runs `mkarchiso`. On Ubuntu it re-enters a privileged `archlinux` container. `packages.x86_64` installs into the **live** root, not the target disk.
- Desktop package list: `aspects/aur/packages` — official repos only (`paru` install commented out). archinstall extra packages: `base-devel`, `git` (`configure.sh`).
- Open standard / platform primitive: pacman local repository (`repo-add` + `[name] Server = file:///…` in `pacman.conf`), documented on ArchWiki Offline installation and Archiso “custom local repository”.
- Already owned tools: `mkarchiso`, `pacman`, `repo-add` (inside the same Arch container the script already starts).
- Explicitly closed: forking `omarchy-iso`, leftover `offline.db` on the installed system, `--skip-ntp` on the official ISO.

`packages.x86_64` is not the Omarchy trick. Adding chromium to that file would put Chromium on the live USB, not on the installed disk, and would still leave `pacstrap` downloading `base`/`linux`.

## Candidates

| Candidate | Class | Exact version/tier | Current evidence | Hard-gate result | Disposition and reason |
|---|---|---|---|---|---|
| Do nothing (current mkiso.sh) | Reuse local | `mkiso.sh` as of 2026-08-28 | Live overlay only; install still uses Rackspace/geo mirrors in `configure.sh` | Fail job | Live `gum` is already offline; pacstrap and desktop are not |
| Adopt / fork omarchy-iso | Open-source application | default branch `quattro`; MIT; build-iso.sh fetched 2026-08-28 | [omacom-io/omarchy-iso](https://github.com/omacom-io/omarchy-iso), [builder/build-iso.sh](https://raw.githubusercontent.com/omacom-io/omarchy-iso/quattro/builder/build-iso.sh) | Fail product fit | Whole quattro contract (omarchy packages, keyring, linux-t2, Node tarball, chroot `omarchy-setup-user`). Local docs already closed this |
| Official local-repo primitive (Wiki + archiso + pacman) | Standard / platform | ArchWiki Offline installation oldid 871846; archiso GPL-3.0; `repo-add` from pacman | [Offline installation](https://wiki.archlinux.org/title/Offline_installation): `pacman -Syw --cachedir --dbpath` then `repo-add`; live `pacman.conf` `[custom] Server = file://…`; comment out `[core]`/`[extra]` | Pass | Same mechanism Omarchy uses; already inside the container `mkiso.sh` starts |
| Adapt Omarchy’s wiring into mkiso.sh | Adapt / wrap | Pattern from quattro `build-iso.sh` + `configs/pacman-offline.conf` (MIT) | Download lists → `pacman -Syw` into `airootfs/…/offline` → `repo-add offline.db.tar.gz` → live `pacman.conf` is offline-only → after archinstall, copy conf + bind-mount repo into `/mnt` | Pass with mitigation | Take the **pattern**, not the product. Mitigation: derive lists from this repo, not `omarchy-*.packages` |
| Bespoke: copy live airootfs / squashfs as the installed system | Bespoke | n/a | ArchWiki forbids this as an install method | Fail | Wrong root, custom live config, not a supported install |

## Evidence ledger

| Candidate | Observation date | Primary source | Finding | Requirement/risk | Uncertainty |
|---|---|---|---|---|---|
| omarchy-iso offline mirror | 2026-08-28 | [build-iso.sh](https://raw.githubusercontent.com/omacom-io/omarchy-iso/quattro/builder/build-iso.sh) | Aggregates `packages.x86_64` + `omarchy-base.packages` + `omarchy-other.packages` + `archinstall.packages`; `pacman -Syw --cachedir $offline_mirror_dir --dbpath /tmp/offlinedb`; `repo-add …/offline.db.tar.gz`; symlink so mkarchiso sees `/var/cache/omarchy/mirror/offline` | Full desktop without network | Their list is ~600–2000 packages; yours is smaller |
| omarchy-iso live pacman.conf | 2026-08-28 | [pacman-offline.conf](https://raw.githubusercontent.com/omacom-io/omarchy-iso/quattro/configs/pacman-offline.conf) | Only `[offline] SigLevel = Never` / `Server = file:///var/cache/omarchy/mirror/offline/`. No `[core]`/`[extra]` | archinstall/pacstrap inherit live conf | `SigLevel = Never` is their workaround for boot-time keyring races; Wiki uses `Optional` |
| omarchy-iso install wiring | 2026-08-28 | `.automated_script.sh` (search hit + README) | `archinstall --skip-ntp --skip-wkd`; copy `/etc/pacman.conf` → `/mnt`; bind-mount offline mirror + `/opt/packages` into the target; desktop install happens **before reboot** | USB still mounted when desktop packages install | If you reboot first, the file:// repo vanishes with the ISO |
| omarchy-iso size | 2026-08-28 | [PR 113](https://github.com/omacom-io/omarchy-iso/pull/113) | quattro ISO ~6.2 GB; ~942 packages installed; they considered a prebuilt btrfs root image as an alternative to pacstrap | USB capacity, build time | Your set has chromium + neovim but not their nvidia/triple-kernel/omarchy pkgs — expect a few GB, not measured |
| omarchy-iso license | 2026-08-28 | [LICENSE](https://raw.githubusercontent.com/omacom-io/omarchy-iso/quattro/LICENSE) | MIT, Copyright 2026 Anton Hvornum | Copying their scripts needs attribution | Fine to read the pattern; do not vendor the product |
| ArchWiki offline | 2026-08-28 | [Offline installation](https://wiki.archlinux.org/title/Offline_installation) oldid 871846 | Canonical recipe: `pacman -Syw --cachedir $PWD --dbpath /tmp/blankdb base linux linux-firmware`; `repo-add`; `[custom] Server = file://`; comment out default repos; `pacman-key --init/--populate` if NTP cannot run | Hard gate: supported install path | Wiki is host+USB, not “bake into ISO”, but the repo shape is the same |
| archiso | 2026-08-28 | [LICENSE on github.com/archlinux/archiso](https://raw.githubusercontent.com/archlinux/archiso/master/LICENSE); Wiki Archiso (Anubis blocked one fetch) | GPL-3.0; profile `packages.x86_64` = live ISO packages; separate `pacman.conf` for **build** vs **live** (`airootfs/etc/pacman.conf`) | Already used by mkiso.sh | Wiki HTML blocked once; mechanism confirmed from Offline installation + omarchy-iso usage |
| archinstall file:// repos | 2026-08-28 | [archinstall#3847](https://github.com/archlinux/archinstall/issues/3847) (open) | `custom_repositories` with `file://` is recognized but “does not install any package from it” (svartkanin, 2025-10-03) | Do not rely on configure.sh `custom_repositories` for offline | Follow-up commit `f8018a6` (2026-03-29) removes local repos when copying to target — live `/etc/pacman.conf` is the reliable channel |
| This repo’s remaining network | 2026-08-28 | `iso/start.sh`, `boot.sh`, `install.sh`, `aspects/fonts/default`, `aspects/nvim/default` | tty1 curls `boot.sh`; `boot.sh` clones GitHub; `install.sh` curls `https://mise.run` if `mise` missing then `mise install --yes`; fonts fetch nerd-fonts zips; nvim fetches an appimage only if no system `nvim` | “No packages downloaded” ≠ “no network” | mise is already in `aspects/aur/packages`, so the curl is avoidable if mise is pacstrapped first |

## Qualitative trade-offs

| Dimension | Do nothing | Fork omarchy-iso | Adapt Wiki/Omarchy pattern into mkiso.sh |
|---|---|---|---|
| Functional fit | Live gum only; install downloads everything | Solves offline by becoming Omarchy | Solves the pacman job if lists + live conf + pre-reboot desktop install are wired |
| Architecture fit | Matches current two-phase path | Quattro ISO contract; conflicts with `exploration/arch-install.md` | Keeps mkiso.sh / archinstall / aspects; adds a local repo artifact and a **must-install-desktop-before-reboot** (or copy-repo-to-disk) rule |
| Maturity | Already shipping | Actively maintained product, not a library | Primitive (`pacman`/`repo-add`/`mkarchiso`) is the Arch platform; glue is yours |
| Security / privacy | Online install, current mirrors | Unsigned offline repo (`SigLevel = Never`); ISO integrity is the trust root | Same trust question; prefer Wiki `SigLevel = Optional` plus shipped `.sig` files unless keyring-init proves painful |
| License | n/a | MIT (attribution if copying scripts) | pacman/archiso GPL; your glue stays yours |
| Operations | Rebuild overlay when you next install | Their release cadence, mirrors, keyring | You rebuild the ISO when package lists change; multi-GB artifact; privileged container already required |
| Performance / size | Small ISO (~releng + gum) | ~6.2 GB | Likely 2–5 GB (unmeasured); chromium dominates |
| Total ownership | Lowest | Highest (foreign desktop + ISO) | Medium: list derivation, prune/retry, archinstall skip-ntp, bind-mount, restore online `pacman.conf` after first boot |
| Time to value | Already done | Fast if you abandon this installer | A few focused changes in `mkiso.sh` + configure/arch-install; one VM proof-of-fit |
| Lock-in / exit | Official ISO | High | Drop the overlay files; official ISO unchanged |
| Whole-system mechanism | Network is the package source | Relocates ownership into their ISO | One extra artifact (local repo) using tools you already run; avoids a second installer |

## Decision

- **Outcome:** adapt
- **Recommendation:** Do not adopt or fork `omarchy-iso`. Extend `bin/arch-install/mkiso.sh` with the **ArchWiki local-repository** primitive — the same `pacman -Syw` + `repo-add` + live `[offline]` `pacman.conf` Omarchy uses — seeded from **this repo’s** lists.
- **Why this wins:** The job is “packages on the ISO so pacman does not download,” not “become Omarchy.” That job is a documented pacman/archiso feature. Omarchy is a full product around that feature (T2 kernel, omarchy packages, plymouth, Node tarball, chroot setup). `mkiso.sh` already has the container and `mkarchiso` call. `aspects/aur/packages` is already the desktop list (official repos only).
- **Strongest counterargument:** A faithful “full desktop like Omarchy” install is not only a build change. Omarchy finishes desktop **packages in the live session** while the ISO repo is mounted. Your path reboots, then runs `install.sh`. After reboot the `file://` repo is gone unless you bind-mount during a chroot install **or** copy the repo onto the disk. Without that sequencing, the ISO is a cache that evaporates.
- **What bespoke glue or ownership remains:**
  1. Build: after `prepare`, `pacman -Syw` the union of releng live extras you care about, archinstall essentials (`base`, `linux`, `linux-firmware`, `limine`, `efibootmgr`, `intel-ucode`, `amd-ucode`, `cryptsetup`, `git`, `base-devel`), and the official names in `aspects/aur/packages`; `repo-add` into `airootfs/var/cache/…/offline/`; write `airootfs/etc/pacman.conf` with only that repo (comment out `core`/`extra`).
  2. Install: `archinstall --skip-ntp --skip-wkd` (and `ntp: false` / `offline: true` in JSON) **only on the custom ISO**. Do not use `mirror_config.custom_repositories` for `file://` (archinstall#3847).
  3. Desktop: run `aur:packages` (or equivalent `pacman -S`) in the target **before reboot**, with the offline repo bind-mounted — **or** copy the repo onto `/mnt` and accept a multi-GB disk cache.
  4. After first boot: restore a normal online `pacman.conf` (core/extra/multilib) unless you want the machine permanently ISO-bound.
  5. Still networked unless you also change them: `iso/start.sh` curl of `boot.sh`, `boot.sh` git clone, `install.sh` `mise.run` + `mise install --yes`, `aspects/fonts/default` nerd-fonts zip.
- **What evidence would change the decision:** archinstall grows reliable `file://` custom repo support and copies it to the target; official releng ships an offline profile; you decide air-gap-after-reboot is required (then copy-repo-to-disk wins over bind-mount); or you reopen “fork omarchy-iso” and abandon this installer.

This remains a proposal until the named decision owner records acceptance. Do not self-accept an agent recommendation.

## Proof of fit

- **Question and representative workload:** Build the custom ISO once; in a VM with **no NIC** (or iptables drop), run configure → archinstall → desktop `pacman -S` of `aspects/aur/packages`. Success = every name in that list is installed; `pacman.log` has no mirror fetch.
- **Success/failure boundary:** Any 404 / “failed retrieving file” from `https://` fails. Missing optional firmware is not a fail unless it is in the list.
- **Execution authority:** not granted by this document. Do not implement until accepted.
- **Exact artifact/version and checksum/signature/provenance:** `archlinux` container image digest + `pacman -Q archiso` inside the container, recorded at spike time.
- **Least-privilege sandbox:** privileged container is already required for `mkarchiso` loop devices (existing `mkiso.sh`). Spike should not mount `~` beyond the repo; no age keys.
- **Network, mounts, credentials, host services, and other authorized exceptions:** build may use network to **fill** the offline repo; the install VM must not.
- **Timebox:** one evening: list derivation + `repo-add` + VM install.
- **Result or unresolved obligation:** not run.

## Ownership and implementation route

- **Upgrade/security/incident owner:** you. Rebuild the ISO when you next install, same as today. Advisory response is “rebuild,” not a live mirror.
- **Supported version/range or service tier:** whatever `archlinux:latest` + `pacman -Sy` resolves the day you build. Pin nothing; the ISO **is** the pin.
- **Dependency boundary:** one directory on the ISO (`file:///var/cache/…/offline/`) and one `pacman.conf` overlay. Do not import omarchy-iso as a submodule. Do not add a second package-list format — parse `aspects/aur/packages` (or extract the `packages=(…)` array into a plain list both tasks read).
- **Rollout and recovery:** custom ISO = offline path; official monthly ISO = online path. If the offline ISO is stale or corrupt, use the official ISO. After a successful custom-ISO install, write stock `pacman.conf` so later `pacman -Syu` uses mirrors.
- **Implementation skills/plan:** if accepted — `planning` for the slice (build overlay, then live-session desktop install, then restore online conf); `tdd`/`testing` only where you can assert “pacman did not use https.” Do not start from `reduce-system-complexity`; this **adds** a repo artifact.

## Exit and re-evaluation

- **Data/configuration export and replacement path:** delete the offline overlay files; `mkiso.sh` is back to gum-only; official ISO unchanged.
- **Removal/migration cost:** leftover `[offline]` in an installed `pacman.conf` if you forget to restore online conf — that is the main footgun.
- **Re-evaluate when:** archinstall gains working local-repo install; you enable AUR/`paru` lines (those packages must be **built** at ISO build time); `mise install` / nerd-fonts must also be offline; official archiso ships an offline profile; USB size or build time becomes painful.

## References

- ArchWiki Offline installation, observed 2026-08-28: https://wiki.archlinux.org/title/Offline_installation (oldid 871846)
- omarchy-iso `quattro` `builder/build-iso.sh`, observed 2026-08-28: https://raw.githubusercontent.com/omacom-io/omarchy-iso/quattro/builder/build-iso.sh
- omarchy-iso `configs/pacman-offline.conf`, observed 2026-08-28: https://raw.githubusercontent.com/omacom-io/omarchy-iso/quattro/configs/pacman-offline.conf
- omarchy-iso LICENSE MIT, observed 2026-08-28: https://raw.githubusercontent.com/omacom-io/omarchy-iso/quattro/LICENSE
- omarchy-iso PR 113 (ISO ~6.2 GB / ~942 pkgs), observed 2026-08-28: https://github.com/omacom-io/omarchy-iso/pull/113
- archinstall#3847 (file:// custom repo does not install), observed 2026-08-28: https://github.com/archlinux/archinstall/issues/3847
- archiso LICENSE GPL-3.0, observed 2026-08-28: https://raw.githubusercontent.com/archlinux/archiso/master/LICENSE
- Local: `bin/arch-install/mkiso.sh`, `bin/arch-install/iso/packages.append`, `aspects/aur/packages`, `exploration/arch-install.md`
