# Step 12 — passmenu (gopass picker on Wayland)

**Parent plan:** [PLAN.sway.md](PLAN.sway.md) step 13  
**Prerequisites:** step 7 ([SPEC.gopass-store.md](SPEC.gopass-store.md)), step 10 ([SPEC.sway-step-9-wofi.md](SPEC.sway-step-9-wofi.md)), step 12 (`wl-clipboard`)  
**Status:** draft (agent-facilitated round 1 — needs human review before implementation)

## Story

On Arch + Sway, `passmenu` picks a gopass entry with `wofi --dmenu` and copies the password via `gopass show -c` (which uses `wl-copy`). On X11 + i3 (Ubuntu or Arch fallback), behavior stays `rofi -dmenu` + `xclip`. One script, session-aware dispatch. A `.desktop` entry makes passmenu launchable from the step 9 wofi app launcher (`$mod+space` → drun).

## Context

| Piece | Location / today |
|---|---|
| Script | `bin/passmenu` — `gopass ls --flat \| rofi -dmenu \| xargs --no-run-if-empty gopass show -c` |
| Password store | `gopass` in `aspects/aur/packages`; **store content** from step 7 |
| Clipboard (Wayland) | `gopass show -c` → `github.com/gopasspw/clipboard` → `wl-copy` when `WAYLAND_DISPLAY` is set |
| Clipboard (X11) | same library → `xclip` / `xsel` |
| Picker (Sway) | wofi dmenu (step 10) — same `~/.config/wofi/style.css` as app launcher |
| Picker (i3) | rofi `-dmenu` — unchanged |
| Launcher entry | none today — add `~/.local/share/applications/passmenu.desktop` so wofi drun can start it |
| Keybind | none in sway/i3 config; shell, wofi drun, or future keybind |

Step 10 covers `$mod+space` app launcher only. Step 7 covers store import. This step covers the gopass password picker script and a drun entry to reach it from that launcher.

## Rules

### R1 — Session-aware picker in `bin/passmenu`

When `WAYLAND_DISPLAY` is non-empty, the script uses wofi dmenu; otherwise rofi dmenu.

**Examples:**
- In Sway: `passmenu` spawns wofi (not rofi).
- In i3/X11: `passmenu` spawns rofi (unchanged).
- Cancel (Escape) → no clipboard write, exit 0.

**Questions:**
- Exact wofi flags — see parked Q1.

### R2 — Entry list and selection unchanged

Picker input is still `gopass ls --flat`; selected line is passed to `gopass show -c`.

**Examples:**
- Store has `web/example.com` → appears in list, filterable by typing.
- Select entry → password on clipboard; `wl-paste` (Sway) or `xclip -o -selection clipboard` (X11) returns it.
- Empty selection (cancel) → `xargs --no-run-if-empty` prevents `gopass show` from running.

### R3 — Clipboard works on Wayland after step 11

In Sway, `gopass show -c` succeeds only when `wl-copy` is available (`wl-clipboard` package, step 12).

**Examples:**
- After picking an entry in Sway VM: `wl-paste` prints the password.
- gopass clears clipboard after ~45s (existing gopass behavior).
- Without `wl-clipboard`, step 12 is not done — picker may open but copy fails.

### R4 — Dual-stack: rofi path preserved on X11

Do not remove rofi usage from the X11 branch. Arch i3 fallback session keeps today’s behavior.

**Examples:**
- Ubuntu i3: `passmenu` still pipes through `rofi -dmenu`.
- No wofi invocation when `WAYLAND_DISPLAY` is unset.

### R5 — Reuses wofi theme from step 10 (dark + light)

Wofi dmenu uses the same dotfiles wofi config and stylesheets as the app launcher (`style.css` / `style-light.css`, switched by darkman). No separate passmenu theme.

**Examples:**
- passmenu wofi window is dark/gruvbox-aligned, consistent with `$mod+space` launcher.
- Optional dmenu-specific overrides (prompt, lines) via command flags only unless Q2 says otherwise.

### R6 — No new packages in this step

Step 13 adds no pacman lines beyond prerequisites (`wofi`, `wl-clipboard`, `gopass` store from step 7).

**Examples:**
- `aspects/aur/packages` diff for step 12 is empty.
- Third-party wrappers (`wofipassmenu`, `passwmenu`, etc.) are not adopted.

### R7 — Desktop entry for wofi drun (and rofi combi on i3)

Add `passmenu.desktop` under `aspects/dotfiles/files/.local/share/applications/` so the password picker appears in the app launcher without a dedicated keybind.

**Examples:**
- `$mod+space` → type "pass" → "Passwords" (or chosen name) → `passmenu` runs → wofi dmenu opens with gopass entries.
- Desktop file: `Exec=passmenu`, `Terminal=false`, `Type=Application`, `Categories=Utility;`.
- Works on Sway (wofi drun, step 9) and i3 (rofi combi drun) — same `.desktop` file both sessions.
- Directory already in dotfiles manifest (`.local/share/applications`).

### R8 — Step complete only after VM proof in Sway

**Examples:**
- Clean Arch VM, Sway running, steps 7, 10, and 12 done.
- `passmenu` → wofi opens with gopass entries.
- `$mod+space` → select passmenu desktop entry → same dmenu flow.
- Pick entry → `wl-paste` returns password.
- From i3/X11 session (if available): `passmenu` still uses rofi and xclip paste works.

## Acceptance criteria

1. `bin/passmenu` branches on `WAYLAND_DISPLAY`: wofi dmenu vs rofi dmenu.
2. Wofi branch uses flags agreed in Q1.
3. `passmenu.desktop` in dotfiles under `.local/share/applications/`.
4. Sway VM: shell `passmenu` and wofi drun entry both reach gopass picker → `wl-paste` shows password.
5. X11/i3 path unchanged (rofi + xclip; same `.desktop` visible in rofi combi drun).
6. PLAN.sway.md step 13 row marked done with commit reference after tests pass.

## Out of scope (step 13)

- Sway/i3 keybind for passmenu (optional; drun entry covers launcher access).
- fish `pbcopy`/`pbpaste` aliases (`xclip`) — separate Wayland clipboard story.
- Removing rofi from Arch.
- OTP / `gopass show -o` variants, `pass` compatibility, or typing password into focused window.

## Parked questions

| ID | Question | Recommendation | Owner | Review by |
|---|---|---|---|---|
| Q1 | Exact wofi dmenu flags? | `wofi --dmenu --prompt pass: -i -M fuzzy -L 15` — fuzzy match like rofi default, case insensitive, reasonable height. | — | before implementation |
| Q2 | Separate wofi dmenu config file? | No — share step 9 `style.css`; flags on CLI are enough unless VM shows layout issues. | — | during implementation |
| Q3 | Detect sway vs other Wayland compositors? | `WAYLAND_DISPLAY` is sufficient; Hyprland path is archived. | — | before implementation |

## Candidate terms

| Term | Gloss |
|---|---|
| **dmenu mode** | stdin list → user picks one line → stdout; rofi `-dmenu`, wofi `--dmenu`. |
| **Session branch** | Runtime choice of wofi vs rofi based on Wayland vs X11, not separate scripts. |
| **Prerequisite chain** | gopass store (7) + wofi (10) + wl-clipboard (12) before passmenu can be marked done on Sway. |

## Implementation hints (non-normative)

```
bin/passmenu  → session branch + wofi/rofi picker
aspects/dotfiles/files/.local/share/applications/passmenu.desktop
```

Sketch:

```bash
#!/usr/bin/env bash

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  picker=(wofi --dmenu --prompt pass: -i -M fuzzy -L 15)
else
  picker=(rofi -dmenu)
fi

gopass ls --flat | "${picker[@]}" | xargs --no-run-if-empty gopass show -c
```

## Review notes

Round 1 (agent draft). Before implementation:

1. Confirm Q1 (wofi flags).
2. Verify steps 7, 10, and 12 are done in VM — step 13 cannot pass without them.
3. Three-amigos pass on R1–R8.
