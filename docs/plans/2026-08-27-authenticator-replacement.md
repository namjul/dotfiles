# Solution Decision: Replace Google Authenticator with exportable phone+desktop TOTP

- **Status:** proposed
- **Decision owner:** you (personal operator)
- **Accepted or rejected by/date:**
- **Evidence date:** 2026-08-27
- **Scope and expected lifetime:** daily 2FA for personal accounts; years; high criticality (account lockout); reversible via `otpauth://` / encrypted export
- **Confidence:** medium — platforms and export are documented; Google Authenticator export quality and your phone OS were not verified in-session

## Job and outcomes

Generate RFC 6238 TOTP codes on a phone and on Linux desktop from the same secrets, without Google as the vault owner. Observable outcomes: import existing Google Authenticator entries, unlock codes offline, produce an encrypted export you can decrypt without the vendor, and recover after phone loss.

Hard constraint from you: **same codes on phone + desktop, still exportable.**

## Hard constraints and non-goals

| Constraint | Hard or preferred | Evidence / owner |
|---|---|---|
| TOTP on phone and native Linux desktop | Hard | Your choice 2026-08-27 |
| Export secrets without vendor lock-in | Hard | Same |
| No Google as source of truth | Hard | Replacement request |
| Stay offline / no account | Preferred | Fits existing age/pass posture; both Ente and Proton allow offline |
| Put TOTP in password-store | Not required | Existing store is passwords/API keys, not a TOTP UI |
| Hardware OATH as primary | Non-goal this round | You did not pick YubiKey-first |
| Build a custom authenticator | Non-goal | High lockout risk, no differentiation |

## Local capabilities inspected

- Existing repository capability: age-backed password store (`gopass`/`passage`), fnox, YubiKey as age identity — no TOTP app or `pass-otp` in aspects.
- Open standard: RFC 6238 TOTP, `otpauth://` URIs.
- Platform primitive: `oathtool` / `pass otp` could generate codes from secrets you already store; no phone UI or QR import.
- Existing tool: Google Authenticator (to leave).

## Candidates

| Candidate | Class | Exact version/tier | Current evidence | Hard-gate result | Disposition and reason |
|---|---|---|---|---|---|
| Ente Auth | Open-source app + optional E2EE sync | Linux/desktop builds tagged `auth-v4.4.25` on ente.com | [ente.com/auth](https://ente.com/auth/), [export docs](https://ente.com/help/auth/migration/export), monorepo AGPL-3.0 | Pass | **Adopt (proposed)** — native Linux + Android/iOS/web, offline mode, encrypted export decryptable to `otpauth://` via official CLI |
| Proton Authenticator | Open-source app + optional Proton sync | Product live 2026; Android repo GPL-3.0, created 2025-07 | [proton.me/authenticator](https://proton.me/authenticator), [android-authenticator](https://github.com/protonpass/android-authenticator) | Pass | Strong peer; younger desktop story; vendor sync is a Proton account |
| 2FAS Auth | Open-source mobile + browser extension | Mobile + Chrome/Firefox/Safari extension; no native desktop on [2fas.com/download](https://2fas.com/download/) | Official download page lists mobile + browser only | **Fail** native desktop | Phone remains the generator; extension is a relay, not a Linux vault |
| Aegis | Open-source Android app | v3.4.2 (2026-02-24) | [beemdevelopment/Aegis](https://github.com/beemdevelopment/Aegis) GPLv3, Play/F-Droid | **Fail** desktop | Best Android-only vault; use as import source or offline backup, not the primary if desktop is required |
| Password-store + `pass otp` / `oathtool` + Aegis | Adapt / combine / bespoke | N/A | Local encryption.md; no otp aspect today | Pass with glue | More mechanism; secrets next to passwords; no first-class phone sync |

Do-nothing (keep Google Authenticator) fails the replacement and historically weak export/backup posture.

## Evidence ledger

| Candidate | Observation date | Primary source | Finding | Requirement/risk | Uncertainty |
|---|---|---|---|---|---|
| Ente Auth | 2026-08-27 | https://ente.com/auth/ | Android, iOS, Mac, Linux, Windows, web; offline without account; AGPL monorepo | Desktop + export | Linux package vs GitHub release install not exercised |
| Ente Auth | 2026-08-27 | https://ente.com/help/auth/migration/export | Encrypted export: Argon2id + XChaCha20-Poly1305; decrypt to newline-separated `otpauth://`; `ente auth decrypt`; local daily encrypted backups | Exit / recovery | CLI not run here |
| Proton Authenticator | 2026-08-27 | https://proton.me/authenticator | Android, iOS, Windows, Mac, Linux; no account required; E2EE sync if Proton Account; claims direct export | Desktop + export | Export format and Linux artifact not fetched from a help page in this run |
| Proton Authenticator | 2026-08-27 | https://github.com/protonpass/android-authenticator | GPL-3.0; repo created 2025-07-23 | Maintenance horizon | Desktop/Linux source location not inspected |
| Aegis | 2026-08-27 | GitHub README + v3.4.2 release | TOTP/HOTP, encrypted vault, import from Google Authenticator, plaintext or encrypted export, Android only | Phone vault / migration | Import from current Google Authenticator version untested |
| 2FAS | 2026-08-27 | https://2fas.com/download/ | Native apps: mobile; desktop path is browser extension | Desktop hard gate | Extension pairing quality unused |

## Qualitative trade-offs

| Dimension | Ente Auth | Proton Authenticator | Store + oathtool/Aegis |
|---|---|---|---|
| Functional fit | Phone + Linux + web; import/export documented | Same platform claim; import advertised | Desktop easy; phone is a second vault you keep in sync by hand |
| Architecture fit | Separate 2FA app; optional vendor cloud | Separate 2FA app; optional Proton cloud | Collapses 2FA into password-store threat model |
| Maturity | Longer-lived Auth product, CLI, published crypto export | Newer standalone product (2025+) | You already operate age/pass |
| Security/privacy | Offline OK; sync is E2EE + Ente account | Offline OK; sync is E2EE + Proton account | No new vendor; one compromise hits passwords and TOTP |
| License | AGPL-3.0 (ente/ente) | GPL-3.0 (Android client) | Existing store licenses |
| Recovery | Encrypted export + official decrypt CLI + local backups | Vendor claims backup/export | Git-backed store + paper age key already planned |
| Operations | App updates; optional account | App updates; optional Proton account | You own `pass otp` entries and Aegis backups |
| Total ownership | Low if you adopt the apps as designed | Similar | Highest glue: QR, mobile, backup format |
| Lock-in / exit | `otpauth://` after decrypt | Claims direct export; verify once | Already portable `otpauth` if you store URIs |
| Whole-system mechanism | One dedicated authenticator | One dedicated authenticator | Second path next to any future phone app |

## Decision

- **Outcome:** adopt
- **Recommendation:** **Ente Auth** on Android (or iOS) and Linux. Use **offline mode** unless you explicitly want their E2EE sync. Keep an encrypted export somewhere that is not only the phone (existing age/pass or offline disk).
- **Why this wins:** Only class that meets phone + native Linux + documented secret export without inventing sync. Proton is a close second if you already live in Proton and prefer their account for sync.
- **Strongest counterargument:** Proton may be “good enough” with a simpler product surface; Ente’s optional cloud is another company holding ciphertext. Aegis is a better *Android* vault if you later drop the desktop requirement.
- **What bespoke glue remains:** One-time migration from Google Authenticator; a backup location you already trust; optional later `pass otp` copies of the highest-value issuers.
- **What evidence would change the decision:** Proton’s Linux client + export format proven equivalent in a 30-minute spike; you decide desktop is “browser extension is enough” (then 2FAS); you decide TOTP must live only in the password-store.

This remains a proposal until you accept it. Nothing was installed.

## Proof of fit

- **Question:** Can you import Google Authenticator and see the same code on phone and Linux for one throwaway TOTP (e.g. a new GitHub dummy or a local `oathtool` secret)?
- **Success/failure:** Same 6-digit window on both devices; encrypted export decrypts to `otpauth://` with official CLI.
- **Execution authority:** not granted — do not install until you accept.
- **Timebox:** 30–45 minutes after install.

## Ownership and implementation route

- **Upgrade/security/incident owner:** you
- **Supported version/range:** current Ente Auth stable (`auth-v4.x`); prefer F-Droid or official GitHub Linux build over random AUR copies
- **Dependency boundary:** authenticator app only; do not fold TOTP into fnox/dotfiles
- **Rollout:** import → verify 2–3 accounts → encrypted export → then remove entries from Google Authenticator
- **Implementation:** no repo change unless you later add an AUR package pin

## Exit and re-evaluation

- **Export:** Ente encrypted export → `ente auth decrypt` → `otpauth://` lines → Aegis / Proton / `pass otp`
- **Re-evaluate when:** Ente Auth unmaintained; Linux client breaks; you add a Proton-only workflow; YubiKey OATH becomes the primary factor; a password-store OTP workflow is already daily

## References

- https://ente.com/auth/ — Auth product; `auth-v4.4.25` desktop links; observed 2026-08-27
- https://ente.com/help/auth/migration/export — export crypto and CLI; observed 2026-08-27
- https://github.com/ente/ente — AGPL-3.0; observed via product page 2026-08-27
- https://proton.me/authenticator — platforms, optional account, export claim; observed 2026-08-27
- https://github.com/protonpass/android-authenticator — GPL-3.0; observed 2026-08-27
- https://github.com/beemdevelopment/Aegis — v3.4.2; GPLv3; observed 2026-08-27
- https://2fas.com/download/ — mobile + browser extension only; observed 2026-08-27
