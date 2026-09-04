# Solution Decision: clipboard access — Clipper vs GPaste

- **Status:** proposed
- **Decision owner:** nam (repo operator)
- **Accepted or rejected by/date:**
- **Evidence date:** 2026-09-01
- **Scope and expected lifetime:** personal workstation + optional remote SSH/tmux; years
- **Confidence:** high that the two projects are not substitutes; medium on “which to install here” because the first ask was a repo-vs-repo comparison without a single job
- **Lineage:** conversation compared [wincent/clipper](https://github.com/wincent/clipper) and [Keruspe/GPaste](https://github.com/Keruspe/GPaste), then checked what [Omarchy](https://github.com/basecamp/omarchy) ships (`~/code/tries/2026-08-31-omacom-omarchy`) and why that tree treats remote clipboard as a non-goal

## Job and outcomes

Compare Clipper and GPaste as given. They share the word “clipboard” and BSD-2-Clause licenses; they do not share a job.

- **Clipper job:** expose the *local* system clipboard (and optional notifications) to local/remote tmux and editors via a loopback or UNIX-socket daemon, typically forwarded with SSH `RemoteForward`. Outcome: yank on a remote host lands in the laptop clipboard.
- **GPaste job:** a *desktop clipboard manager* for GNOME — persistent named histories, GTK 4 UI, GNOME Shell extension, D-Bus daemon, search/favourites/passwords. Outcome: recall previous copies on the local desktop.

A winner of “which clipboard tool” is undefined. A winner is only defined after picking one of those jobs.

This machine’s repo already treats clipboard as `wl-clipboard` on Wayland and `xclip` on X11 (`90-aliases.fish`); Arch Sway bootstrap already lists `wl-clipboard` for screenshots (`aspects/aur/PLAN.md`). Neither Clipper nor GPaste is in-tree.

## Hard constraints and non-goals

| Constraint | Hard or preferred | Evidence / owner |
|---|---|---|
| Not GNOME Shell as the daily compositor | Hard for *this* repo if installing a desktop manager | Sway is the Arch compositor; Hyprland dropped (`aspects/aur/PLAN.md`) |
| Wayland-native clipboard write | Preferred on Arch | Existing `wl-copy` alias |
| No new GNOME Shell / mutter stack for clipboard | Preferred | Avoid second desktop stack |
| Do not invent a shared “clipboard product” | Hard for the original comparison | Owner chose “compare as given” |
| Implementation / install | Out of scope | Research only |

## Local capabilities inspected

- Existing repository capability: `pbcopy`/`pbpaste` aliases → `wl-copy` / `xclip`; screenshot path uses `wl-clipboard`; no history daemon.
- Standard library / open standard: OSC-52 (Clipper README compares this); Wayland `wlr-data-control` via `wl-clipboard`.
- Framework, runtime, platform: Sway + UWSM; Ubuntu i3 + X11 fallback.
- Existing supported dependency/tool: `wl-clipboard`, `xclip`, `wofi`, tmux/nvim stack (not wired to Clipper).

## Candidates

| Candidate | Class | Exact version/tier | Current evidence | Hard-gate result | Disposition and reason |
|---|---|---|---|---|---|
| Do nothing / local primitives | reuse | `wl-clipboard` + `xclip` as already adopted | PLAN.md, fish aliases, 2026-09-01 | pass for current “copy now” job | Satisfies local copy/paste; not history; not remote yank |
| Clipper | OSS tool | **3.0.0** (tag 2026-04-24); repo `pushed_at` 2026-04-28 | GitHub release + README | pass for remote-yank; fail for history/UI | Not a manager; Linux default executable is `xclip`, not `wl-copy` |
| GPaste | OSS application | **50.9** stable (tag + Arch `extra` 50.9-1, 2026-08-31); **51.beta** for GNOME 51 | README, tags API, archlinux.org | pass for GNOME history; fail as Sway-native history (GNOME/mutter/extension-first) | Packed, actively released; wrong compositor fit here |
| Omarchy clipboard (reference, not a candidate to install) | bespoke app | tree `~/code/tries/2026-08-31-omacom-omarchy` | `manual/08-unified-clipboard-history.md`, `shell/plugins/clipboard/` | pass as an existence proof of the Sway-shaped path | `wl-clipboard` + in-shell history; not Clipper, not GPaste |
| Bespoke baseline | build | OSC-52 and/or `wl-paste --watch` + store + `wofi` picker | Clipper FAQ; existing wofi; Omarchy plugin | pass if owner wants either job without these products | Smaller mechanism than GPaste on Sway; remote yank may not need a daemon |

## Evidence ledger

| Candidate | Observation date | Primary source | Finding | Requirement/risk | Uncertainty |
|---|---|---|---|---|---|
| Clipper | 2026-09-01 | https://github.com/wincent/clipper + release `3.0.0` | Go daemon; tmux/`nc`/`socat`; SSH `RemoteForward`; optional UNIX socket; structured `notification` protocol in 3.0.0 | Remote yank | AUR `clipper-git` last updated 2022-06-03 at 2.0.0-era rev — packaging lag |
| Clipper | 2026-09-01 | README Security | No auth; default loopback TCP 8377; any local user can *push* clipboard; recommends UNIX socket + per-user perms | Multi-user / forwarded socket | Residual risk if TCP + SSH `-R` misconfigured |
| Clipper | 2026-09-01 | README FAQ | Text-oriented; images/binary not first-class; OSC-52 alternative with payload-size caveats | Large/binary copies | Not independently benchmarked |
| Clipper | 2026-09-01 | LICENSE.txt / GitHub license | BSD-2-Clause | License gate | — |
| Clipper | 2026-09-01 | GitHub security page; OSV search | No SECURITY.md; no published advisories; OSV list empty for `wincent/clipper` | Security process | Absence of advisories ≠ audited |
| GPaste | 2026-09-01 | README | GNOME clipboard manager: daemon, GTK 4/libadwaita UI, Shell extension, CLI; encryption (libsodium), SQLite/XML; portal shortcuts | Desktop history | Headless/Sway UX without Shell extension is second-class |
| GPaste | 2026-09-01 | tags + https://archlinux.org/packages/extra/x86_64/gpaste/ | v50.9; Arch extra 50.9-1 built 2026-08-31 | Distro currency | Ubuntu universe lags (upstream README) |
| GPaste | 2026-09-01 | COPYING / GitHub license | BSD-2-Clause | License gate | — |
| GPaste | 2026-09-01 | GitHub security; OSV `gpaste` | No SECURITY.md; no project advisories; GHSA hit is **nasm** `gpaste_tokens` (unrelated) | Name collision in advisory search | — |
| GPaste | 2026-09-01 | repo metadata | `updated_at`/`pushed_at` 2026-08-31; 22 open issues; C | Maintenance | — |
| Omarchy | 2026-09-01 | `install/omarchy-base.packages`, `shell/plugins/clipboard/` | Package is `wl-clipboard`. History is QML in `omarchy-shell`: `wl-paste --watch` (text + `image/png`) → `capture.sh` → `ClipboardHistory.js`. Super+C/X/V; Super+Ctrl+V for history | Local history on a wlroots compositor | Not packaged for this repo; Hyprland-shaped bindings |

## Qualitative trade-offs

| Dimension | Clipper 3.0.0 | GPaste 50.9 | Bespoke / current / Omarchy-shaped |
|---|---|---|---|
| Functional fit | Remote/local *write* to OS clipboard; no history, search, images | History, types, passwords, UI, GNOME integration | Local write already works; history or remote yank would be extra |
| Architecture fit | Small Go daemon + `nc`; Linux clipboard helper is `xclip` by default | GLib/GTK4/D-Bus/systemd user unit; GNOME-shaped | Matches Sway/`wl-copy` |
| Maturity | Long-lived (2013); 3.0.0 Apr 2026; sparse releases | Very active 2026 GNOME 50 line | Already owned (`wl-clipboard`); Omarchy proves the history pattern |
| Security/privacy | Unauthenticated push; socket vs TCP matters; handler stdin is untrusted JSON | Persistent clipboard store (secrets risk); optional encryption + keyring | No extra store unless you add one |
| License | BSD-2-Clause | BSD-2-Clause | N/A |
| Operations | User unit / launchd; SSH forward hygiene | `gpaste-client daemon-reexec` after upgrade; Shell extension enablement | Aliases only; Omarchy watchers die with the shell (`setpriv --pdeathsig`) |
| Performance | Designed for large text vs OSC-52 truncation | History size/memory limits | N/A |
| Total ownership | Config + tmux/nvim/ssh + Wayland helper override | GNOME/GTK stack + history policy | Lowest if current job is enough |
| Lock-in/exit | Stop unit; drop forwards; data is the OS clipboard | Export/migrate histories via client; GNOME-shaped settings | Trivial |
| Whole-system mechanism | Adds a network-facing (loopback) write path | Adds a clipboard *database* and desktop app | Adds nothing until history or yank is chosen |

## What Omarchy uses (2026-08-31 tree)

Not Clipper. Not GPaste.

- **Write path:** `wl-clipboard` (`wl-copy` / `wl-paste`).
- **History:** first-party shell plugin (`shell/plugins/clipboard/`), documented in `manual/08-unified-clipboard-history.md`.
- **Remote desktop clipboard:** explicit non-goal in `plans/remote.md` (Sunshine/Moonlight). Windows VMs are a different case — RDP already shares a clipboard (`manual/28-windows-vm.md`).

That is the compositor-native paste-watch + local store + picker path, not a GNOME manager and not a remote-yank daemon.

## Rationale against a remote clipboard (Omarchy remote plan)

Omarchy’s “no” is about **Sunshine/Moonlight clipboard sync**, not Clipper-style SSH yank. From `plans/remote.md` open question 2:

1. **The streamer does not carry it.** Text-only clipboard sync was proposed and closed as not planned ([LizardByte/Sunshine#5384](https://github.com/LizardByte/Sunshine/issues/5384)). Moonlight has no transport. There is nothing to enable in the stack they already ship.
2. **A homemade bridge is a new product.** `wl-clipboard` over Tailscale between two Omarchy boxes is buildable, but it is a new always-on sync daemon with a security surface (unauthenticated push of whatever is on the clipboard, including secrets). Same class of risk Clipper documents for loopback TCP `:8377`.
3. **It only helps a slice of users.** A two-Omarchy pipe does nothing for Mac, Windows, or phone Moonlight clients.
4. **Scope.** Remote desktop v1 is pairing, display, audio, and uninstall. Clipboard sync would be its own plan.

They still want clipboard **on one machine**. They treat **cross-machine** clipboard as extra mechanism until the streamer grows a transport.

Clipper remains a different job (SSH/`nc` yank into the *local* OS clipboard). It does not contradict Omarchy’s Sunshine non-goal, and it does not become a history manager.

## Decision

- **Outcome:** defer (as a pairwise pick); do not treat Clipper or GPaste as a replacement for the other
- **Recommendation:**
  1. Do not choose Clipper *or* GPaste as “the clipboard tool.” They fail each other’s hard functional gates.
  2. For **this** Sway/Arch repo: keep `wl-clipboard` / `xclip`. Do **not** adopt GPaste unless the session becomes GNOME. If the missing job is **remote yank**, **adapt** Clipper 3.0.0 (UNIX socket, `executable: wl-copy` on Wayland) *or* try OSC-52 first (already in terminals; Clipper’s own FAQ). If the missing job is **history**, prefer a wlroots path (`wl-paste --watch` + a store + wofi), which is the class Omarchy already implemented — not GPaste.
- **Why this wins:** job mismatch is evidenced by both READMEs; local compositor is Sway; GPaste’s first-class path is GNOME Shell; Clipper is a write-proxy, not a manager; Omarchy confirms the history path without those two products.
- **Strongest counterargument:** if the daily desktop were GNOME, GPaste 50.9 on Arch extra would be the straightforward history adopt; Clipper would still be a separate remote-yank decision.
- **What bespoke glue remains:** Clipper needs `wl-copy` flags, SSH `RemoteForward`, tmux/`nc` binds; GPaste on Sway would still need a compositor-compatible capture story (likely incomplete).
- **What would change the decision:** compositor change to GNOME; a documented GPaste-on-Sway primary path; Sunshine/Moonlight growing a clipboard transport; or a hard requirement for authenticated remote clipboard (neither Clipper nor GPaste provides that).

This remains a proposal until the named decision owner records acceptance.

## Proof of fit

- **Question:** Does Clipper 3.0.0 with `executable=wl-copy` land remote tmux yanks in the Sway clipboard? Does GPaste daemon + UI function without gnome-shell?
- **Success/failure:** Clipper: remote `nc` → local clipboard in <1s, no listen on non-loopback. GPaste: history UI after copy in a Sway session without installing Shell.
- **Execution authority:** not granted (no install).
- **Exact artifact:** Clipper 3.0.0; GPaste 50.9 / Arch `gpaste` 50.9-1.
- **Least-privilege sandbox:** not run.
- **Exceptions:** none.
- **Timebox:** 30–60 minutes if later authorized.
- **Result:** unrun.

## Ownership and implementation route

- **Upgrade/security/incident owner:** nam, if accepted
- **Supported version:** Clipper 3.0.0+ (avoid stale AUR `clipper-git` 2022); GPaste track GNOME major (50.x now)
- **Dependency boundary:** Clipper as a user daemon only; do not wrap GPaste types through the repo
- **Rollout:** not authorized
- **Implementation skills:** `planning` / `manage-aspects` only after accept

## Exit and re-evaluation

- **Export:** Clipper — none (OS clipboard). GPaste — `gpaste-client` / migrate.
- **Removal:** stop user unit / pacman `-R gpaste`
- **Re-evaluate when:** compositor change; Clipper unmaintained; GPaste Wayland-non-GNOME support; OSC-52 payload limits become acceptable/unacceptable; Sunshine/Moonlight clipboard transport appears

## Conversation

Compared the two GitHub repos as given (not as substitutes). Then: what does Omarchy use? Then: rationale against a remote clipboard? This file is the durable write-up of that thread.

## Open threads

- Pick a job (remote yank vs local history) before any install.
- OSC-52 spike vs Clipper 3.0.0 + `wl-copy` if yank is the job.
- If history is the job: how much of Omarchy’s plugin vs `wl-paste --watch` + wofi is worth owning here.

## References

- https://github.com/wincent/clipper — README, LICENSE.txt, release 3.0.0 (2026-04-24), repo activity through 2026-08-21
- https://github.com/Keruspe/GPaste — README, COPYING, tags v50.9 / v51.beta, activity 2026-08-31
- https://archlinux.org/packages/extra/x86_64/gpaste/ — 50.9-1 (2026-08-31)
- https://aur.archlinux.org/packages/clipper-git — last updated 2022-06-03
- https://osv.dev/list?q=wincent%2Fclipper and `gpaste` — no relevant hits (2026-09-01)
- Local: `aspects/aur/PLAN.md`, `aspects/dotfiles/files/.config/fish/conf.d/90-aliases.fish`
- Omarchy tree: `~/code/tries/2026-08-31-omacom-omarchy` — `manual/08-unified-clipboard-history.md`, `plans/remote.md`, `shell/plugins/clipboard/`
