# Specification map: ungoogled-chromium

story: Replace stock Chromium as the default browser with Ungoogled Chromium (Arch packaging: ungoogled-chromium-archlinux)

rules:
  - rule: Ungoogled Chromium is the default handler for web schemes and HTML, in the same slots stock Chromium occupies today
    examples:
      - Today `mimeapps.list` sets `x-scheme-handler/http`, `https`, `about`, `unknown`, and `text/html` to `chromium_chromium.desktop`. After this story, those keys resolve to the installed Ungoogled `.desktop` id (packaging currently installs `chromium.desktop`; confirm at prove), not a leftover Google-only id.
      - Today `x-scheme-handler/webcal` is `chromium.desktop`. After this story it uses the same Ungoogled desktop id as the other web keys.
    questions:
      - Exact `.desktop` id on this machine after install — packaging source installs `chromium.desktop`; current mimeapps mostly uses `chromium_chromium.desktop`. Confirm at prove, then set all six keys to that one id.
  - rule: After Ungoogled Chromium is installed and handlers are retargeted, the stock `chromium` package is gone
    examples:
      - `pacman -Q ungoogled-chromium-bin` succeeds. `pacman -Q chromium` fails. Arch packaging declares `conflicts=('chromium')` and `provides=('chromium=...')`, so stock Chromium cannot stay installed beside Ungoogled; removal is forced by the package, not only by a later manual uninstall.
  - rule: Switch order is install and prove Ungoogled, then retarget handlers/specs, then drop stock Chromium from the aspect list
    examples:
      - Until install, `chromium` remains installed and `mimeapps.list` still points at `chromium_chromium.desktop`. Only after Ungoogled has been proven on this machine do we change mimeapps/wofi/`aspects/aur/packages`. Installing the AUR `-bin` package will then conflict with / replace `chromium`.
  - rule: Proven means one GUI launch that shows the existing profile, plus the Ungoogled package query succeeding
    examples:
      - After `pacman -Q ungoogled-chromium-bin` succeeds, launching Ungoogled Chromium shows bookmarks or a known site from the current `~/.config/chromium` profile. That pair is enough to retarget; days of daily-driver use are not required. `pacman -Q` alone is not enough.
  - rule: Launchers and specs use the Ungoogled package's real binary and `.desktop` name
    examples:
      - Arch packaging installs `/usr/bin/chromium` and `chromium.desktop` (same names as extra/chromium). Confirm at prove. Do not invent an `ungoogled-chromium` command or wrapper unless the installed package actually ships that name.
  - rule: The existing Chromium user profile is reused, not wiped or copied into a new tree
    examples:
      - After the switch, opening Ungoogled Chromium shows the same bookmarks and open-profile data that lived in `~/.config/chromium` before stock `chromium` is gone. No second empty profile is created unless the package itself refuses that directory.
    questions:
      - If the package uses a different user-data dir than `~/.config/chromium`: stop and confirm; do not silently copy or wrap.
  - rule: Keep the existing Chromium flags template; do not rename it for Ungoogled
    examples:
      - After the switch, `~/.config/chromium-flags.conf` (from `aspects/dotfiles/templates/.config/chromium-flags.conf.tmpl`) is still the flags file. The Arch package uses foutrelis chromium-launcher v8, which reads `/etc/chromium-flags.conf` then that user path. Ozone/Wayland, touchpad history, and `--load-extension` into `~/.local/share/chromium/extensions/...` stay as written. No `ungoogled-chromium-flags.conf`.
  - rule: First slice is the running system plus repo files that already treat desktop Chromium as the default
    examples:
      - In scope: `mimeapps.list`, `aspects/aur/packages` (`chromium` → `ungoogled-chromium-bin` at retarget), wofi spec wording if the installed names differ. Out of scope: `docs/plans/2026-08-28-offline-iso-packages.md`, Playwright's `npx playwright install chromium`, the historical gtk-portal note in `aspects/aur/PLAN.md` (`chromium` Ctrl+O), and the flags template path (already correct).

questions:
  - Where does this story live? → this file
  - Outcome? → replace stock Chromium as default
  - Remove the `chromium` package after the switch? → yes; packaging `conflicts=('chromium')` also forces it
  - How does the package get onto the machine? → AUR `ungoogled-chromium-bin` via makepkg/paru (AUR PKGBUILD path, not unofficial binary repo). The `-bin` PKGBUILD unpacks a prebuilt Chromium; it does not compile Chromium.
  - Profile? → reuse `~/.config/chromium` as-is
  - webcal? → retarget with the other handlers
  - Launcher name? → package binary/desktop name as-is (packaging currently: `chromium` / `chromium.desktop`; confirm at prove)
  - First-slice scope? → running system + repo handlers/specs only
  - Profile dir mismatch? → stop and confirm; no silent copy/wrapper
  - Switch order? → install + prove, then retarget, then remove/replace via conflict + packages list
  - What counts as proven? → one GUI launch showing existing profile + `pacman -Q ungoogled-chromium-bin`
  - PLAN.md portal note? → leave unchanged
  - `aspects/aur/packages`? → swap `chromium` for `ungoogled-chromium-bin` at retarget
  - Flags file? → keep `chromium-flags.conf` as-is
  - Exact Ungoogled `.desktop` id? → park until prove (owner: nam). Then unify http/https/about/unknown/html/webcal to that one id. Packaging source installs `chromium.desktop`.

acceptance criteria:
  - After prove, `mimeapps.list` http/https/about/unknown/html/webcal all use the same installed Ungoogled `.desktop` id (no leftover `chromium_chromium.desktop` unless that is the proven id)
  - `pacman -Q ungoogled-chromium-bin` succeeds and `pacman -Q chromium` fails, in that order relative to prove-then-retarget
  - After retarget, `aspects/aur/packages` lists `ungoogled-chromium-bin` and no longer lists `chromium`
  - The first Ungoogled window shows the pre-switch `~/.config/chromium` profile; if it does not, stop and confirm instead of copying or wrapping
  - `~/.config/chromium-flags.conf` remains the flags file; the template is not renamed
  - ISO notes, Playwright Chromium, PLAN.md, and the flags template path stay unchanged unless prove shows a different launcher name

candidate terms:
  - ungoogled-chromium-archlinux: Arch packaging repo for Ungoogled Chromium (https://github.com/ungoogled-software/ungoogled-chromium-archlinux)
  - ungoogled-chromium-bin: AUR package that installs a prebuilt Ungoogled Chromium via makepkg (the README "Binary Downloads" path). Not chaotic-aur or other unofficial repos.
  - ungoogled-chromium: AUR from-source package name (not used for S1)
  - chromium-launcher: Arch wrapper (`foutrelis/chromium-launcher`) that reads `chromium-flags.conf`; shipped by both extra/chromium and ungoogled-chromium-archlinux

## Story split

### Parent

Nam can use Ungoogled Chromium as the daily default browser on this machine, with the existing profile and flags, without stock Chromium coming back on the next aur sync.

Constraint: installing the AUR `-bin` package conflicts with `chromium`, so prove cannot sit beside stock Chromium; mimeapps today uses two desktop ids.

### Recommended first slice

Nam can open Ungoogled Chromium on this machine and see the existing profile (and existing flags).

Why this first: burns the install/conflict/profile risk. If prove fails (blank profile, missing launcher), later handler and packages-list work can stop. If no later slice ships, Nam still has a daily browser via `chromium` / the installed desktop file.

### Split candidates

| Slice | Value | Includes | Defers | Acceptance Examples | Release Constraint |
|---|---|---|---|---|---|
| S1. Nam opens Ungoogled and sees the existing profile | Daily browser exists; learn desktop id, binary name, profile dir | AUR `ungoogled-chromium-bin` on the running system (makepkg/paru, not unofficial repo); one GUI launch; record proven `.desktop` id and command; keep `chromium-flags.conf` | mimeapps unify; `aspects/aur/packages` swap; wofi spec edit | Given stock Chromium is still the installed extra package, when the AUR `-bin` package is built and installed, then `pacman -Q ungoogled-chromium-bin` succeeds and `pacman -Q chromium` fails. Given the existing `~/.config/chromium` profile, when Nam launches the installed command, then bookmarks or a known site from that profile are visible. Given `~/.config/chromium-flags.conf`, when the launcher starts, then `chromium --help` still lists that flags file (or the window shows the same Wayland/extension behavior as today). If the profile dir is not `~/.config/chromium`, stop and confirm. | Shippable on this machine; repo files unchanged |
| S2. Nam's http(s)/html/webcal links open Ungoogled | Clicks and file associations match the new default | After S1 prove, set mimeapps http/https/about/unknown/html/webcal to the proven desktop id; update wofi spec only if the proven command is not `chromium` | `aspects/aur/packages`; ISO; Playwright; PLAN.md | Given S1 recorded desktop id `D`, when mimeapps is updated, then those six keys all equal `D`. Given a local `https://` link or HTML file, when opened with the desktop opener, then Ungoogled receives it. Typing `chromium` in wofi opens Ungoogled if that is the proven command. | Shippable in the dotfiles repo |
| S3. Next aur sync does not bring stock Chromium back | Machine and repo stay on Ungoogled | After S1, `aspects/aur/packages` lists `ungoogled-chromium-bin` and not `chromium` | ISO package set; any other Chromium mentions | Given the packages file after the swap, when an aur install/sync is considered, then it would request `ungoogled-chromium-bin` and would not reinstall extra `chromium`. | Shippable in the repo; can follow S1 even if S2 is dropped |

### Parking lot

- Profile-dir mismatch: stop and confirm (no migrate story until that happens)
- Exact desktop id until S1 prove
- ISO / Playwright / PLAN.md out of scope
- Flags template rename: not a story

### Warnings

- S1 and S2 are sequential: install replaces `chromium` immediately (`conflicts`), so some `chromium_chromium.desktop` keys may fail until S2. That gap is accepted.
- S3 without S2 still prevents stock Chromium from returning; handlers may stay wrong.
- Do not split “write PKGBUILD / change mimeapps / change packages” as separate stories; those are tasks inside S1–S3.
- Wofi spec is not its own story: only change it if S1 proves a name other than `chromium`.

### Next step

S1 selected. Implementation plan: `plans/ungoogled-chromium-s1.md`. S2/S3 unplanned.
