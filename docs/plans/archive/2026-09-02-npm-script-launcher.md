# Solution Decision: Launch package.json scripts quickly from fish

- **Status:** proposed (re-evaluated 2026-09-02; ni 30.5.0 adopted in mise)
- **Decision owner:** you (personal operator)
- **Accepted or rejected by/date:**
- **Evidence date:** 2026-09-02
- **Scope and expected lifetime:** daily personal CLI; low criticality; reversible
- **Confidence:** high on history vs TUI; high that dum already satisfies the remaining job

## Job and outcomes

Run a named `package.json` script without `npm run` startup cost. After that, **Ctrl-R / up-arrow must replay the same script** from fish history.

You rejected fzf-make (no gruvbox/theme). The remaining question is only the fast typed runners.

## Hard constraints and non-goals

| Constraint | Hard or preferred | Evidence / owner |
|---|---|---|
| Replay from fish history | **Hard** | You: launchers often left only the picker name in history |
| Theme/gruvbox for a TUI | Hard for any new TUI | fzf-make chrome is hardcoded; no config |
| Keep a picker TUI | Non-goal | You dropped fzf-make |
| Microsecond win over `dum` | Non-goal | You already use `run` → `dum run` |

## Local capabilities inspected

- `abbr run 'dum run'` expands on Space/Enter. Fish stores the **expansion** in history (`dum run test`), not the token `run`. That is the history property you want. (fish `abbr` docs; same reason people prefer abbr over alias.)
- Node 24 is already pinned in mise → `node --run` is available with no extra binary.
- `fzf-make` 0.73.0 was pinned then rejected (colors + TUI exec).
- `dum` is not pinned in this repo’s mise/aur list; it is an existing machine tool the abbr already assumes.

## Candidates

| Candidate | Class | Exact version/tier | Hard-gate: history of the script | Disposition |
|---|---|---|---|---|
| Keep `run` → `dum run` | Reuse | dum already on PATH | **Pass** — history is `dum run <script>` | **Do nothing** (keep) |
| nrr | Open-source CLI | benches cite v0.10.2 (2025–26); `nrr test` / `nrr run test`; fish completions | **Pass** if you type/complete `nrr test` | Reject for now — same job as dum, new pin, ~0.4 ms |
| `node --run` | Runtime primitive | Node 24 in mise | **Pass** — you type `node --run test` | Reject — slower than dum; longer to type |
| ni `nr` / px | PM router | not pinned | **Pass** only for `nr test`; **fail** for bare `nr` (interactive, history is `nr`) | Reject — wrong job; interactive path fails the new gate |
| fzf-make / ntl / fzf picker that execs | TUI | fzf-make 0.73.0 | **Fail** — history is `fzf-make` / `fm` | **Rejected** — you; also no theme |

## Evidence ledger

| Candidate | Observation date | Primary source | Finding |
|---|---|---|---|
| fish abbr | 2026-09-02 | https://fishshell.com/docs/current/cmds/abbr.html ; https://ddbeck.com/notes/fish-shell-abbrs/ | Expansion is what runs and what history searches |
| nrr | 2026-09-02 | https://github.com/ryanccn/nrr/ | `nrr dev`; fish `COMPLETE=fish nrr`; faster than dum in their hyperfine |
| dum | 2026-09-02 | same nrr README bench | 2.0 ms vs nrr 1.6 ms vs `node --run` 6.1 ms vs npm 155 ms |
| fzf-make UI | 2026-09-02 | crate `ui.rs` | Hardcoded RGB mint + OneHalfDark; execs inside the process |

## Qualitative trade-offs

| Dimension | dum + `run` abbr | nrr | node --run |
|---|---|---|---|
| History | `dum run test` | `nrr test` | `node --run test` |
| Pick without TUI | Type the name (or add completions later) | Built-in script-name completions | Node completions if installed |
| Ownership | Already there | New crate pin + completions | Zero extra binary |
| Speed | Fast enough | Slightly faster | Still ≪ npm; slower than dum |

## Decision

- **Outcome:** **adopt** `@antfu/ni` **30.5.0** (mise `npm:@antfu/ni`); keep `run` → `dum run`; fzf-make stays dissolved
- **Recommendation:** Use typed `nr <script>` (tab-complete) so history is `nr test`. Bare `nr` / `ni -i` / `nr -p` stay interactive on purpose. `ni`, `nlx`, `nun`, `nup`, `nci`, `nd`, `na` are the extras.
- **Why this wins:** The new hard gate kills in-process pickers. dum already meets speed + history. nrr is a lateral move.
- **Strongest counterargument:** nrr’s fish completions would help you *choose* a name without a TUI while still writing `nrr test` into history. Adopt nrr only if tab-complete of scripts is the next pain.
- **What would change it:** You want script-name completion, or dum disappears from the machine (then pin nrr or switch the abbr to `node --run`).

## Ownership

- **Runner:** you already own dum; this repo only owns the abbr.
- **fzf-make:** uninstall + drop pin.

## Exit and re-evaluation

- Re-evaluate if you want completion-driven pick (nrr) or dum is gone.
