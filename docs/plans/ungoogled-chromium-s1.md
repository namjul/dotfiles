# Plan: Ungoogled Chromium S1 (prove install)

**Branch**: none (S1 does not change repo files)
**Status**: Active — blocked in agent session 2026-09-02: source downloaded and sha256 ok; `makepkg` dies on `chown` (`fakeroot` broken here); `sudo pacman -U` refused (`no new privileges`). Finish S1 in a normal user terminal.
**Story**: `docs/plans/2026-09-02-ungoogled-chromium.md` (S1)

## Goal

Nam can launch Ungoogled Chromium on this machine and see the existing `~/.config/chromium` profile (and existing `chromium-flags.conf`).

## Acceptance Criteria

- [ ] `pacman -Q ungoogled-chromium-bin` succeeds
- [ ] `pacman -Q chromium` fails (package conflict, not a later manual uninstall)
- [ ] One GUI launch of the installed command shows bookmarks or a known site from the pre-switch `~/.config/chromium` profile
- [ ] If the user-data dir is not `~/.config/chromium`, stop and confirm (no copy, no `--user-data-dir` wrap)
- [ ] `chromium --help` (or equivalent launcher output) still reports `~/.config/chromium-flags.conf` when that file exists
- [ ] Proven `.desktop` id and command are written into the spec note
- [ ] Repo files stay unchanged (`mimeapps.list`, `aspects/aur/packages`, wofi spec, flags template, PLAN.md, ISO notes)

## Install vehicle (constraint)

`aspects/aur/packages` installs official-repo packages via `pacman`. Paru install is commented out. AUR lines are comments. S1 therefore **cannot** be `mise r //aspects/aur:packages` until S3 (or a separate paru enablement).

Default for this plan: AUR `ungoogled-chromium-bin` on this machine (`makepkg -si` from the AUR git, or `paru -S ungoogled-chromium-bin` if paru is already on PATH). Still the AUR PKGBUILD path (not chaotic-aur / unofficial repos). The PKGBUILD downloads a prebuilt Chromium; it does not compile Chromium. `conflicts=('chromium')` removes extra/chromium in the same install.

This machine has `makepkg` and no `paru`. Install:

```bash
git clone https://aur.archlinux.org/ungoogled-chromium-bin.git
cd ungoogled-chromium-bin
makepkg -si
```

## Slices

### Slice 1: Nam opens Ungoogled and sees the existing profile

**Value**: Daily browser exists after stock Chromium is replaced; desktop id / command / profile dir become facts for S2/S3.
**Path**: AUR `-bin` install → package conflict drops `chromium` → launcher `/usr/bin/chromium` (confirm) + `chromium-flags.conf` → GUI window on `~/.config/chromium` → record proven names in the spec note.
**Class**: Behavior change (machine), no repo behavior.
**Delivery**: No PR. Operational on this machine. Exploration note update after prove is optional documentation, not required to “ship” the browser.
**Required implementation skills**: `N/A` for TDD/testing/refactoring. `mutation-testing`: `N/A`.
**Reduction program**: `N/A`
**Transition/terminal evidence**: `N/A`
**Acceptance criteria**: Same as plan-level list above.
**RED or preservation baseline**: No automated test. Baseline before install: `pacman -Q chromium` succeeds; profile dir exists; flags file exists.
**GREEN or preservation change**: Install `ungoogled-chromium-bin` via AUR makepkg; prove GUI + profile; record facts. Do not edit mimeapps or `aspects/aur/packages` in this slice.
**REFACTOR**: `N/A`
**PRE-PR MUTATION or alternate evidence**: `N/A` — operational evidence: `pacman -Q` pair, one GUI launch, launcher `--help` flags-file line, recorded desktop id (`ls /usr/share/applications/*chrom*`).
**PR-ready when**: `N/A` (no PR). Slice ready when AC checkboxes are true.
**Slice complete when**: Prove recorded; Nam can use Ungoogled as the installed `chromium` command even if S2/S3 never happen.

## Out of this plan

S2 mimeapps unify. S3 `chromium` → `ungoogled-chromium-bin` in `aspects/aur/packages`. Enabling paru in the aspect. ISO / Playwright / PLAN.md. Compiling AUR `ungoogled-chromium` from source.

---
*Delete this file when S1 is complete. If `plans/` is empty, delete the directory.*
