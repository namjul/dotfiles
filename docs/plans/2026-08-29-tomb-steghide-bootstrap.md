# Solution Decision: Keep vs replace JPEG → tomb → Dropbox → GPG

- **Status:** proposed
- **Decision owner:** hobl
- **Accepted or rejected by/date:**
- **Evidence date:** 2026-08-29
- **Scope and expected lifetime:** Personal bootstrap for the gopass GPG identity and the Dropbox tomb that holds it. Horizon is the remaining Ubuntu→Arch / age-store migration, then retirement of Dropbox as store location.
- **Confidence:** medium-high on architecture and steghide/tomb facts; medium on live tomb upstream release tagging (no GitHub Releases page; local/vendored Tomb is 2.11.0).

## Job and outcomes

**Job:** On a new or rebuilt machine, recover the GnuPG private key that decrypts the existing gopass store, without putting a plaintext key in git, and without depending on a second person.

**Operator:** one person (hobl). **Observable outcomes:** `gpg` can decrypt current store entries; `fnox` pass-provider secrets still resolve; a documented recovery path exists if Dropbox or the JPEG is lost.

A decision is needed now because this chain is the *current* recovery path, while `docs/plans/encryption.md` already aims at age + private git and “no Dropbox” for the store. Keeping both without a verdict doubles mechanism.

## Hard constraints and non-goals

| Constraint | Hard or preferred | Evidence / owner |
|---|---|---|
| Age identity never committed in git | Hard | `docs/plans/encryption.md`, `bin/arch-install/arch-install.md` |
| Password store not long-term on Dropbox | Preferred (already decided as target) | `docs/plans/encryption.md` |
| Linux, existing mise/fnox/age, gopass today | Hard | repo + local versions 2026-08-29 |
| Do not send secrets to a new hosted vault | Hard | personal-control; no procurement |
| Deniability / “looks like a painting” | Preferred only if it does not weaken crypto | user-described current design |
| Implement or migrate in this evaluation | Non-goal | skill contract |

## Local capabilities inspected

- Existing repository capability: fnox age provider (`aspects/dotfiles/files/.config/fnox/config.toml`, pin `fnox = "1.21.0"`); already stores ciphertext in git. Age USB restore is the documented Arch bootstrap. `docs/plans/encryption.md` already names “SOPS/fnox for PGP private keys in the public repo” as later work.
- Standard / open standard: `age` (local `v1.3.1`), OpenPGP via gopass/GnuPG (local `gopass 1.16.1`).
- OS primitive: LUKS (install path), cryptsetup/tomb LUKS containers.
- Existing tools: vendored `bin/tomb` **2.11.0** (Jul 2024); live `tomb` on PATH is Dropbox copy of same version; `steghide 0.5.1`; JPEG in repo `aspects/dotfiles/files/.config/i3/Albert_Bierstadt,_Among_the_Sierra_Nevada_Mountains.jpg` (not opened/exhumed in this evaluation).

**Reuse finding:** The bury passphrase in fnox age is only usable *after* `~/.config/age/key.txt` (or equivalent) works. That is already the real bootstrap. Stego + tomb do not unlock a machine that cannot decrypt fnox.

## Candidates

| Candidate | Class | Exact version/tier | Current evidence | Hard-gate result | Disposition and reason |
|---|---|---|---|---|---|
| A. Keep JPEG bury + fnox passphrase + Dropbox tomb + GPG | Adapt / current compose | Tomb 2.11.0; steghide 0.5.1 | Tomb bury uses steghide; project warns KDF+stego conflict | Fail preferred store location; fail “key and data stay apart” once JPEG is in a cloneable repo | Reject as *security* design; optional cold backup only |
| B. Age + fnox (or SOPS) for an armored GPG export; store via private git | Existing local capability | age 1.3.1; fnox 1.21.0 (upstream 1.29.0 exists) | Official fnox age docs: ciphertext in git | Pass | **Recommend** as replacement for the *key* path |
| C. Tomb without stego (key on USB, container elsewhere) | Open-source tool | Tomb 2.11.0 | Official bury is optional; LUKS container remains | Pass if Dropbox is only temporary | Defer as *optional* bulky backup, not daily path |
| D. Bespoke: new wrapper / new crypto around bury | Bespoke baseline | n/a | Would add scripts around a weak steg layer | Fail total-ownership vs B | Reject |
| E. New hosted password manager | Managed service | n/a | Would move secrets off local control | Fail hard “no new vault” | Reject |

## Evidence ledger

| Candidate | Observation date | Primary source | Finding | Requirement/risk | Uncertainty |
|---|---|---|---|---|---|
| Tomb bury/exhume | 2026-08-29 | https://dyne.org/docs/tomb/ ; https://github.com/dyne/Tomb/blob/master/INSTALL.md ; `doc/tomb.1` | JPEG bury via steghide; intended as unsuspected *backup*, not a public-repo key | Deniability vs public git | GitHub “Releases” empty; version from local/vendored 2.11.0 |
| Tomb + stego vs KDF | 2026-08-29 | https://github.com/dyne/Tomb/blob/master/KNOWN_BUGS.md | Steghide dictionary attacks bypass KDF; same password for steg and key; bury assumes attacker does not have both image and tomb | Password brute force | Whether this install used KDF: not checked (would require opening the vault) |
| steghide 0.5.1 | 2026-08-29 | https://nvd.nist.gov/vuln/detail/CVE-2021-27211 ; Debian tracker still **vulnerable** on 0.5.1 | 32-bit seed: hidden-data *detection* (and extract if encryption off) without the password | Public JPEG in git is a known steg cover | Tomb still encrypts payload with the passphrase; detection ≠ full decrypt |
| gopass store sync | 2026-08-29 | https://github.com/gopasspw/gopass/blob/master/docs/setup.md | Official recommendation: private **git**, not Dropbox; GPG key is a GnuPG concern, not a gopass feature | Store location | — |
| fnox age | 2026-08-29 | https://fnox.jdx.dev/providers/age.html | Age ciphertext in `fnox.toml` is the supported “secrets in git” path | Already used for API keys | Local pin 1.21.0 vs upstream 1.29.0 (plugins); not required to choose B |
| encryption.md | 2026-08-29 | repo | Target: age store, GitHub, no Dropbox; PGP via SOPS/fnox listed as later | Consistency | Phase 1 not finished |

## Qualitative trade-offs

| Dimension | A Keep bury chain | B Age + fnox for GPG export | D Bespoke wrapper |
|---|---|---|---|
| Functional fit | Works today if Dropbox + image + age + passphrase all exist | Same outcome once age works; fewer hops | Same outcome, more code |
| Architecture fit | Conflicts with written age/git target; circular with fnox | Matches encryption.md and install USB story | Second path |
| Maturity | Tomb maintained; steghide last-line 0.5.1, CVE unfixed | age + fnox already in mise | You own all bugs |
| Security | Public cover + known steg detection; Dropbox has ciphertext *and* sync metadata; tomb model assumes key and tomb stay separated | One crypto family; multi-recipient already planned | Inherits A’s steg risk |
| Recovery | Many moving parts (Dropbox client, steghide, tomb, GPG) | Age stick + clone + `fnox get` / import | Worse |
| Total ownership | High (four tools, two clouds/repos) | Low (tools already owned) | Highest |
| Lock-in / exit | Tomb file + GPG export still portable | Age armor portable | Scripts rot |
| Whole-system mechanism | Relocates the GPG key behind extra layers that do not raise the age bar | Removes layers | Adds layers |

## Decision

- **Outcome:** adapt (replace the *key* path; do not invent a new product)
- **Recommendation:** Treat the JPEG bury + Dropbox tomb as a **legacy cold backup**, not the design to keep. After age works on a machine, recover or store the GPG secret as **age ciphertext via fnox (or SOPS)** as already parked in `docs/plans/encryption.md`. Move the password store off Dropbox per that doc (private git). Do not add automation around `tomb bury`/`exhume`.
- **Why this wins:** The bury passphrase is already an fnox age secret. Anyone who can decrypt fnox can exhume. Anyone who cannot decrypt fnox cannot use the painting. Stego therefore adds detection risk and operational surface, not an extra gate. Tomb’s own docs and KNOWN_BUGS assume the image is *not* an obvious, cloneable singleton.
- **Strongest counterargument:** The painting-in-git *is* a memorable recovery story and the tomb may still hold more than GPG. Until the GPG export is duplicated under age, deleting Dropbox or the JPEG would be lockout.
- **What bespoke glue remains:** A one-time, manual `gpg --export-secret-keys` (or equivalent) into fnox/SOPS; keep a paper/USB age identity; optional keep the tomb file offline until that export is verified.
- **What evidence would change the decision:** A requirement that the GPG key must remain deniable *and* must not appear as age blobs in git; or a machine class that has Dropbox+steghide+tomb but cannot run age/fnox (none in this repo’s install path).

This remains a proposal until the named decision owner records acceptance.

## Proof of fit

- **Question:** Can an armored GPG secret be stored and retrieved with the existing fnox age provider without opening the tomb?
- **Success/failure:** `fnox get` yields importable secret-key material; gopass decrypts one known entry. Failure: fnox size/encoding limits or pinentry issues.
- **Execution authority:** not granted in this evaluation (no exhume, no vault open, no key import).
- **Exact artifact/version:** fnox 1.21.0, age 1.3.1, gopass 1.16.1 — re-record at spike time.
- **Least-privilege sandbox:** disposable VM or tmpfs; no network; no Dropbox mount unless explicitly allowed.
- **Timebox:** 30–60 minutes once authorized.
- **Result:** not run.

## Ownership and implementation route

- **Upgrade/security/incident owner:** hobl
- **Supported version/range:** keep current fnox/age pins until a separate bump; do not add steghide as an Arch/Ubuntu hard dependency for bootstrap
- **Dependency boundary:** GPG material is a fnox/SOPS secret or an age file; tomb is not in the daily path
- **Rollout and recovery:** verify export while tomb still mounts; then stop treating the JPEG as required
- **Implementation skills/plan:** `planning` / existing `docs/plans/encryption.md` Phase 1; no new aspect

## Exit and re-evaluation

- **Export:** GPG secret-key armor; tomb can stay copied to USB until two successful imports
- **Removal cost:** low after verified age copy (delete or stop syncing tomb; leave JPEG as wallpaper)
- **Re-evaluate when:** store converted to age (GPG may leave entirely); steghide upstream fix; Dropbox policy change; fnox 1.29+ YubiKey recipients adopted

## References

- Tomb manual: https://dyne.org/docs/tomb/ (observed 2026-08-29)
- Tomb INSTALL + bury: https://github.com/dyne/Tomb/blob/master/INSTALL.md
- Tomb KNOWN_BUGS steganography: https://github.com/dyne/Tomb/blob/master/KNOWN_BUGS.md
- Tomb 2.11.0 local/vendored `bin/tomb` header DATE Jul/2024
- steghide CVE-2021-27211: https://nvd.nist.gov/vuln/detail/CVE-2021-27211 ; Debian https://security-tracker.debian.org/tracker/CVE-2021-27211 (0.5.1 still vulnerable, 2026-08-29)
- gopass setup (git vs cloud folders): https://github.com/gopasspw/gopass/blob/master/docs/setup.md
- fnox age: https://fnox.jdx.dev/providers/age.html ; fnox 1.29.0 https://github.com/jdx/fnox/releases/tag/v1.29.0
- Local plan: `docs/plans/encryption.md`
