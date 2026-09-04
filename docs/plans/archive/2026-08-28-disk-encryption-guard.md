# Solution Decision: Whether to require a crypt device before `install.sh`

- **Status:** accepted (supersedes the do-nothing proposal)
- **Decision owner:** you (personal operator)
- **Accepted or rejected by/date:** accepted 2026-08-28 — ISO erase requires LUKS; TUI/dual-boot must enable it (collateral)
- **Evidence date:** 2026-08-28
- **Scope and expected lifetime:** this machine's Arch bootstrap contract; years; reversible (re-add a preflight line or add autologin later)
- **Confidence:** high for the login pairing (local scripts + Omarchy ISO source); medium that live Omarchy ISO still matches the July checkout

## Job and outcomes

Decide whether `b59c14e1` (drop `lsblk … TYPE=crypt` in `aspects/aur/preflight`) should stay, come back, or be replaced by Omarchy's encryption + autologin pairing.

Users: you, installing or reinstalling Arch from this repo. Observable outcomes: `install.sh` can finish on a disk you chose not to encrypt; a sitting-down stranger does not get a desktop without a password; at-rest theft risk is explicit.

A decision is needed now because the guard is already gone and Omarchy's reason for requiring LUKS (autologin) is not the same as this repo's login path.

## Hard constraints and non-goals

| Constraint | Hard or preferred | Evidence / owner |
|---|---|---|
| LUKS is optional at install time (`Ctrl+C` in gum) | Hard (current product) | `bin/arch-install/configure.sh` `encrypt=false` default; `docs/plans/arch-install.md` calls LUKS taste, not structure |
| SDDM greeter, not autologin | Hard (current product) | `aspects/aur/login/sddm.sh` enables `sddm.service` only; no `autologin.conf` |
| Passwordless `Default_keyring` is deployed | Current fact | `aspects/aur/login/default-keyring.sh` |
| Do not fork Omarchy ISO / quattro | Hard | `aspects/aur/PLAN.md`, `docs/plans/arch-install.md` |
| Do not invent a third login manager | Preferred | SDDM already owned in `aur` |
| VM / fig-test installs must not need LUKS | Hard | `in_test_or_vm` already skipped the old guard |

Non-goals: choosing age vs LUKS for secrets; changing `configure.sh` disk UI; implementing autologin in this decision.

## Local capabilities inspected

- Existing repository capability: preflight abort (root, sudo); optional LUKS in `configure.sh`; SDDM without autologin; passwordless gnome-keyring
- Standard / OS primitive: LUKS (`cryptsetup` / archinstall `disk_encryption`); `lsblk` TYPE=`crypt` (only true after unlock)
- Framework: mise `//aspects/aur:preflight` before packages
- Existing supported tool: archinstall 4.3 JSON we already write; Omarchy used as a reference, not a runtime dependency

The old guard (`45992346`) was added with gnome-keyring: passwordless keyring files "guarded by disk encryption check in preflight." It was not added because this repo shipped autologin. It also failed closed on a *locked* LUKS disk (`lsblk` shows `crypt` only after unlock), so it was a "session already decrypted" check, not an "installer configured LUKS" check.

## Candidates

| Candidate | Class | Exact version/tier | Current evidence | Hard-gate result | Disposition and reason |
|---|---|---|---|---|---|
| A. Do nothing — keep `b59c14e1` | reuse local | HEAD `b59c14e1` | Greeter is the session gate; LUKS stays optional | Pass | **Recommend** — already matches Omarchy's unencrypted pairing |
| B. Adopt Omarchy default — FDE + SDDM autologin | adapt Omarchy 3.8.5 | omarchy `f4378f0d` (3.8.5, 2026-08-14) | LUKS is the only gate after boot; autologin.conf | Fail current product | Reject — fights optional LUKS and "omit autologin" in `aspects/systemd/PLAN.md` |
| C. Restore preflight crypt abort | reuse old local | `45992346` line | Blocks `install.sh` unless a mapping is open | Fail optional-LUKS | Reject — same friction that caused `b59c14e1`; does not configure LUKS, only refuses later |
| D. Pairing (Omarchy ISO unencrypted path) — no crypt ⇒ no autologin; crypt ⇒ may autologin | adapt omarchy-iso | iso `168c6ed` (2026-07-20) | `configure_login_for_unencrypted_install` deletes `autologin.conf` when encrypt is false | Pass | Already true for the no-autologin half; do not add the encrypted-autologin half unless you want it |
| E. Bespoke — encrypt the keyring when there is no crypt device | build | n/a | Would change `default-keyring.sh` | Pass | Defer — solves at-rest keyring only; more mechanism than this decision |

## Evidence ledger

| Candidate | Observation date | Primary source | Finding | Requirement/risk | Uncertainty |
|---|---|---|---|---|---|
| B / docs | 2026-08-28 | https://omarchy.org/manual/getting-started/ | Default is full encryption. `Ctrl+C` on disk confirm installs without encryption for "special circumstances." | Omarchy default vs optional | Marketing page can drift from ISO |
| B / DHH | 2026-08-28 | https://github.com/basecamp/omarchy/issues/1281 (quoted) | "Full-disk encryption is integral to the default security setup of Omarchy since we do autologin." | Why they require LUKS on the ISO path | Issue thread, not a versioned spec |
| B | 2026-08-28 | local omarchy `f4378f0d` `install/login/sddm.sh` | Writes `/etc/sddm.conf.d/autologin.conf` (`User=$USER`, `Session=omarchy`) if missing | Autologin is the installed default | Checkout is 3.8.5, not necessarily today's `master` |
| D | 2026-08-28 | local omarchy-iso `168c6ed` `.automated_script.sh` L213–244 | If `user_encrypt_installation.txt` is `false`, delete `autologin.conf` and getty autologin. Comment: unencrypted installs must stop at SDDM; encrypted path may autologin because the disk password was already entered. | Pairing, not "always require crypt" | ISO checkout 2026-07-20; live ISO may have moved |
| A | 2026-08-28 | `aspects/aur/login/sddm.sh` | No `autologin.conf`; enable greeter only | We are already on the unencrypted pairing | — |
| C | 2026-08-28 | `git show 45992346` / `b59c14e1` | Guard added with keyring; removed so unencrypted install can run preflight | Wrong tool for optional LUKS | — |
| A residual | 2026-08-28 | `aspects/aur/login/default-keyring.sh` | Passwordless keyring on disk with `lock-on-idle=false` | At-rest secrets if no LUKS | Same as rest of `$HOME` without FDE |

## Qualitative trade-offs

| Dimension | A Do nothing | B FDE + autologin | C Restore crypt abort | E Keyring-if-no-crypt |
|---|---|---|---|---|
| Functional fit | Greeter password; LUKS optional; `install.sh` runs | Walk-up desktop after LUKS; no greeter password | Stops bootstrap on plain root | Session still has greeter; keyring may prompt |
| Architecture fit | Matches `configure.sh` + current `sddm.sh` | Imports Omarchy session model we already rejected | Install-time policy in the wrong phase (after disk exists) | Touches keyring only |
| Security | At-rest open without LUKS; session gated | At-rest + boot gated by LUKS; no second password | Refuses to install; does not encrypt | Shrinks keyring exposure; not the disk |
| Total ownership | None | Autologin files, LUKS-required install, lock-screen story | One `lsblk` line + false VM/lock failures | New branch in `default-keyring.sh` |
| Whole-system mechanism | Least | Relocates the password to initramfs | Extra refuse path | Extra policy branch |

## Decision

- **Outcome:** adapt (erase path forces LUKS; TUI does not write `disk_encryption`; preflight refuses a missing crypt mapping except VM/test)
- **Recommendation:** Require LUKS on **Erase entire disk**. In the TUI, tell the operator to enable LUKS; do not invent a JSON encryption block for a disk we do not own. Restore the preflight `lsblk` TYPE=`crypt` abort (VM/test skipped; proceed-anyway still exists) so a dual-boot miss fails at `install.sh`. Write SDDM autologin to Sway as `$USER` (`aspects/aur/login/sddm.sh`).
- **Why this wins:** You chose the Omarchy pairing: LUKS at boot, then autologin. Erase can write LUKS. Dual-boot cannot; preflight is the catch. Autologin is Sway as `$USER`, not an Omarchy session or theme.
- **Strongest counterargument:** proceed-anyway on preflight plus autologin is an unlocked desktop on a plain disk. Do not write `autologin.conf` if you later drop the crypt guard.
- **What bespoke glue or ownership remains:** `/etc/sddm.conf.d/autologin.conf`; PAM patch also applied to `sddm-autologin` when that file exists.
- **What evidence would change the decision:** dropping the crypt guard; or wanting a greeter again.

This remains a proposal until you record acceptance. Do not treat this file as an ADR until then.

## Proof of fit

Not required. Live check: `grep -E '^(User|Session)=' /etc/sddm.conf.d/autologin.conf` shows this user and `sway`; `systemctl is-enabled sddm`.

## Ownership and implementation route

- **Upgrade/security/incident owner:** you
- **Supported version/range:** current `sddm.sh` + `configure.sh` LUKS toggle
- **Dependency boundary:** Omarchy stays a reference; no new package
- **Rollout and recovery:** already shipped in `b59c14e1`
- **Implementation skills/plan:** none unless you accept and then ask to document the pairing in `arch-install.md` / `PLAN.md`

## Exit and re-evaluation

- **Replacement path:** restore the `lsblk` line, or adopt B (autologin + required LUKS)
- **Removal/migration cost:** one commit either way
- **Re-evaluate when:** autologin is added; `configure.sh` drops the no-LUKS toggle; Omarchy ISO pairing is copied into this repo

## References

- This repo: `b59c14e1`, `45992346`; `aspects/aur/preflight`; `aspects/aur/login/sddm.sh`; `aspects/aur/login/default-keyring.sh`; `bin/arch-install/configure.sh`; `aspects/systemd/PLAN.md` (omit autologin)
- Omarchy 3.8.5 `f4378f0d` (observed 2026-08-28): `install/login/sddm.sh` autologin block
- omarchy-iso `168c6ed` (observed 2026-08-28): `configs/airootfs/root/.automated_script.sh` `configure_login_for_unencrypted_install`
- https://omarchy.org/manual/getting-started/ — default encryption; `Ctrl+C` for none (fetched 2026-08-28)
- https://github.com/basecamp/omarchy/issues/1281 — DHH: FDE integral because autologin
