# Pi extensions

A small collection of [Pi](https://github.com/earendil-works/pi/tree/main/packages/coding-agent) extensions that are general enough to be portable across machines and users. Each extension is a self-contained TypeScript module with no dependencies outside of `@earendil-works/pi-coding-agent`, `@earendil-works/pi-tui`, and the Node standard library.

## Type-checking

Run `npm run typecheck` from this directory. It runs `tsc --noEmit`, and runs `bin/install-types` first when the type stubs are missing. Run `bin/install-types` again after a Pi upgrade.

Do not run `npm install` here. These extensions use the dependencies of the installed Pi, and this directory only needs their type declarations.

## Extensions

### `edit-answer.ts`

`/edit-answer` opens the latest assistant answer in `$EDITOR` (falling back to `vim`), then installs the edited text into the composer, so a corrected or reformatted answer can be resent instead of retyped. `/edit-answer pick` selects from the 20 most recent assistant answers, labelled with relative time and an 80-character preview. TUI only.

The editor runs as a trusted shell command with the file passed as `$1`, and Pi's terminal is released for the duration. `lib/dialog.ts` serializes editor and picker dialogs, because Pi has a single editor slot that other custom UIs snapshot and restore.

### `notify.ts`

When a turn ends and pi is waiting for input, this extension sends a `notify-send` notification that stays up until dismissed. It does this only when pi has a UI. The summary names where pi runs, the pi session, and, inside tmux, the pane. Clicking it focuses that place: inside tmux it switches the client to the pane and then focuses the terminal window; in a bare terminal it focuses the terminal window. Spawn errors are ignored.

The notification is skipped when that place is already in view. The terminal is found by walking parents to the pid niri reports for a window: from the tmux client inside tmux, from pi's own process otherwise. Inside the sandbox `process.pid` is namespace-local, so the walk starts from the pid in `/proc/self/stat`, which the host sees. Inside tmux the pane must also be drawn, meaning `window_visible_layout` of an attached client's current window includes it, which excludes background windows and panes hidden behind a zoom. The skip needs the terminal to be the niri-focused window, so a visible pane in an unfocused terminal still notifies.

### `quote.ts`

`/quote [text]` and `alt+q` insert selected or copied text into the editor as `>`-prefixed lines, so a comment can be written under the excerpt. `/quote text` quotes its argument verbatim.

`alt+q` reads the fullscreen highlight first (`getActiveSelectionText`, without opening a dialog), then text copied since the last lookup, then a `selection-hook` selection that changed since the last lookup. Nothing unchanged is ever re-quoted, and with nothing new the shortcut warns instead of inserting a stale value. A copy outranks the selection on purpose: `selection-hook` on Linux only reads PRIMARY and reports no program or coordinates, so a browser selection keeps being returned after its highlight is gone, which would shadow the transcript text just copied. A drag inside fullscreen Pi stays on the alt-screen until mouse-up copies it, and that copy is async, so the highlight is read first and the clipboard check covers the rest.

`alt+q` rather than `ctrl+/`: a legacy terminal sends Ctrl+/ as raw `0x1F`, which cannot be named as a symbol, and a shifted layout (for example German, where `/` is `shift+7`) reports `ctrl+shift`.

On Wayland, `wl-paste` is read before the native X11 helper: `DISPLAY` is set under XWayland, and that helper would return the empty X11 selection while tmux `clip` and Pi have written with `wl-copy`.

### `sandbox.ts`

Shows `Sandbox ✔` in the TUI footer when `IN_SANDBOX` is non-empty. This is a launcher hint, not verification of sandbox enforcement.

### `web-search.ts`

Registers a `web_search` tool that queries the [Kagi Search API](https://help.kagi.com/kagi/api/search.html). It needs `KAGI_API_TOKEN` in the environment. Each query costs $12 per 1,000 searches. The tool takes a query and returns titles, URLs, and snippets.
