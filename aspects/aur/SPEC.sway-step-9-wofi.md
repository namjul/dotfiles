# Step 9 — wofi (app launcher)

**Parent plan:** [PLAN.sway.md](PLAN.sway.md) step 10  
**Status:** done — `78ef905f` (VM verified)

## Story

On Arch + Sway, replace the X11 `rofi` launcher bind with native Wayland `wofi`, so `$mod+space` opens a keyboard-driven app launcher inside the Sway session. Ubuntu + i3 keeps `rofi` unchanged.

## Context

| Current (rofi) | Location |
|---|---|
| Keybind | `$mod+space` in `aspects/dotfiles/files/.config/i3/config` and `.../sway/config` |
| Command | `rofi -show combi` |
| Config | `aspects/dotfiles/files/.config/rofi/config.rasi` — modes `drun`+`run`, combi searches `drun` only, `@theme "gruvbox-dark"` |
| Theme toggle | `~/.local/share/dark-mode.d/rofi` and `light-mode.d/rofi` sed `@theme` in `config.rasi` |
| Other rofi use | `bin/passmenu` still pipes through `rofi -dmenu` — step 13 in [PLAN.sway.md](PLAN.sway.md) |

Sway config already exists and is Arch-only (`skipOnDebian` in `aspects/dotfiles/index.ts`). i3 config is Ubuntu-only (`skipOnArch`).

## Rules

### R1 — Package installed on Arch

`wofi` is added to `aspects/aur/packages` and installable via the aur aspect.

**Examples:**
- After `mise r aur:packages` (or equivalent), `pacman -Q wofi` prints a version string and exits 0.
- Fresh Arch VM with dotfiles applied has `wofi` on PATH: `command -v wofi` succeeds.

### R2 — Sway keybind launches wofi, not rofi

In `aspects/dotfiles/files/.config/sway/config`, `$mod+space` execs wofi. The bind must not invoke `rofi`.

**Examples:**
- In a running Sway session, pressing `$mod+space` opens the wofi window centered/overlaid on the focused output.
- `grep 'mod+space' ~/.config/sway/config` shows a line containing `wofi`, not `rofi`.
- i3 config on Ubuntu is unchanged: still `rofi -show combi`.

**Questions:**
- Exact wofi invocation for combi parity — see parked Q1.

### R3 — Launcher finds and starts applications

The wofi session opened by `$mod+space` lists `.desktop` applications and launches the selected entry when confirmed.

**Examples:**
- Type `chromium`, press Enter → Chromium window opens (or focuses existing instance per app behavior).
- Type partial name (`term`), select terminal entry → default terminal launches (`mise r term` bind target or `.desktop` exec).
- Press Escape before selecting → wofi closes, no new window, focus returns to previously focused window.

### R4 — Behavioral parity with rofi combi (drun-only search)

Current rofi config uses combi mode but `combi-modes: [ drun ]` — search covers installed apps, not arbitrary shell commands in the initial view.

**Examples:**
- `$mod+space` → filtered list shows application names/icons from `.desktop` entries, not a bare shell prompt.
- Switching to explicit run/shell mode (if exposed) is optional; default view matches today's rofi combi-dr-only behavior.

**Questions:**
- Whether run mode must remain one keystroke away — see parked Q2.

### R5 — Gruvbox dark + light themes with darkman hooks

Wofi appearance matches rofi parity: gruvbox-dark by default, gruvbox-light when darkman switches to light mode. Same darkman hook pattern as rofi.

**Examples:**
- Default: launcher is visibly dark-themed (not default white wofi).
- After `darkman -u light`: next wofi open uses gruvbox-light stylesheet.
- After `darkman -u dark`: next wofi open uses gruvbox-dark stylesheet.
- Dotfiles include `~/.config/wofi/style.css` (dark), `style-light.css` (light), and `config` pointing at the active stylesheet.
- `~/.local/share/dark-mode.d/wofi` and `light-mode.d/wofi` swap the stylesheet path in `~/.config/wofi/config` (mirror rofi’s `@theme` sed pattern).

**Questions:**
- Shared vs forked theme assets — see parked Q3.

### R6 — Dual-stack: rofi remains on Arch for i3 fallback

Per [PLAN.sway.md](PLAN.sway.md) dual-stack policy, do not remove `rofi` or its dotfiles as part of step 9. Only the Sway session switches to wofi.

**Examples:**
- Arch i3 fallback session: `$mod+space` still runs rofi (if user logs into i3).
- `aspects/dotfiles/files/.config/rofi/config.rasi` remains in the dotfiles manifest.
- No deletion of rofi from `aspects/aur/packages` in this step (rofi may not be listed today; do not add removal work).

### R7 — Step complete only after VM proof in Sway

Package install alone is not completion (same discipline as step 6 done rule).

**Examples:**
- Clean Arch VM, Sway running from TTY (`WLR_RENDERER=pixman sway` or SDDM if later steps done).
- `pacman -Q wofi` passes.
- Manual: `$mod+space` → wofi opens → launch an app → success.
- `grep mod+space ~/.config/sway/config` shows wofi bind after dotfiles apply.

## Acceptance criteria

1. `wofi` in `aspects/aur/packages`.
2. `aspects/dotfiles/files/.config/sway/config`: `$mod+space` execs wofi with agreed flags (Q1 resolved).
3. Dotfiles include `~/.config/wofi/` (`style.css`, `style-light.css`, `config`) plus `dark-mode.d/wofi` and `light-mode.d/wofi` hooks; all registered in `aspects/dotfiles/index.ts`.
4. VM verification checklist (R7) passes in Sway.
5. Ubuntu/i3 path unchanged (no wofi bind in i3 config; rofi config and rofi dark-mode scripts untouched).
6. darkman light/dark toggle switches wofi theme (manual test in VM or on hardware).
7. PLAN.sway.md step 10 row marked done with commit reference after tests pass.

## Out of scope (step 9)

- `bin/passmenu` — step 13 in [PLAN.sway.md](PLAN.sway.md) (after store + `wl-clipboard`).
- Removing rofi system-wide on Arch.
- Hyprland / walker launcher choice (archived in [PLAN.hyprland.md](PLAN.hyprland.md)).
- Keybind changes other than `$mod+space`.

## Parked questions

| ID | Question | Recommendation | Owner | Review by |
|---|---|---|---|---|
| Q1 | Exact wofi command for `$mod+space`? | `wofi --show drun` — matches rofi combi with drun-only search; add `--allow-images` if icons desired. Defer `drun,run` unless run-from-launcher is required daily. | — | before implementation |
| Q2 | Must run/shell mode stay available from the **app launcher** (`$mod+space`)? | No for step 10 — rofi combi already restricts search to drun; terminal is `$mod+Return`. **Unrelated to passmenu** (step 13): passmenu uses `wofi --dmenu`, a separate stdin-driven picker, not the drun launcher. | — | resolved |
| Q3 | wofi theme: minimal CSS vs port full gruvbox rofi theme? | Minimal gruvbox CSS for both dark and light; avoid rofi.rasi port unless gap is obvious in VM test. | — | during implementation |
| ~~Q4~~ | ~~darkman hooks for wofi like rofi?~~ | **In scope for step 9** — see R5. | — | resolved |
| Q5 | Register wofi config as hardlink like rofi? | Symlink/default fig link is fine unless content is identical across machines; rofi uses hardlink for historical reasons — match fig convention for new files (symlink unless proven need). | — | during dotfiles change |

## Candidate terms

| Term | Gloss |
|---|---|
| **Dual-stack** | Arch keeps both i3/X11 and Sway/Wayland sessions; Wayland replacements apply to Sway only. |
| **Combi (rofi)** | Combined drun+run UI; here configured to search drun entries only. |
| **Done rule** | Step not complete until VM behavioral proof, not merely package install. |
| **Sway session** | Arch Wayland desktop reading `~/.config/sway/config`. |

## Implementation hints (non-normative)

For planning after spec stabilizes:

```
aspects/aur/packages          → pacman -S wofi
aspects/dotfiles/files/.config/sway/config → bindsym $mod+space exec wofi …
aspects/dotfiles/files/.config/wofi/       → style.css, style-light.css, config
aspects/dotfiles/files/.local/share/dark-mode.d/wofi   → sed → style.css
aspects/dotfiles/files/.local/share/light-mode.d/wofi  → sed → style-light.css
aspects/dotfiles/index.ts     → add wofi paths to files list
```

Reference diff: compare omarchy sway/i3 launcher setup if present; primary source remains local i3/sway config port table in PLAN.sway.md.

## Review notes

This is round 1 (agent draft). Before `planning` / implementation:

1. Confirm Q1–Q2 (wofi command and run mode).
2. Run three-amigos pass on rules R1–R7 with concrete “what would falsify this?” for each example.
3. Regenerate or annotate review cards if using the specification review template.
