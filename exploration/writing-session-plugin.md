# Writing Session Plugin Plan

## Goal

A focused writing session plugin for Neovim. One command opens a scratch buffer pre-dated, starts a silent word-count + timer on first keystroke, celebrates hitting the word goal, and prompts to save on close.

---

## File location

```
lua/namjul/writing_session.lua   ← plugin implementation
plugin/20_plugins.lua            ← add `later()` block to register command
plugin/21_commands.lua           ← register :WritingSession command
```

No external dependencies. Uses only Neovim builtins (`vim.uv`, `vim.api`, `vim.fn`, `vim.wo`).

---

## Command

```
:WritingSession
```

Optionally accepts args for overrides:

```
:WritingSession max_words=100 max_time=180
```

---

## State model

```lua
{
  buf        = nil,   -- buffer handle
  win        = nil,   -- window handle
  timer      = nil,   -- vim.uv repeating timer (100ms tick)
  start_time = nil,   -- absolute time (vim.uv.now()) of first keystroke
  word_count = 0,
  max_words  = 75,
  max_time   = 120,   -- seconds
  -- derived flags (set once, never reset)
  words_goal_met        = false,
  time_expired          = false,
  celebration_running   = false,
}
```

---

## Lifecycle

```
:WritingSession
  → Config.new_scratch_buffer()
  → insert date header `# YYYY.MM.DD `
  → enter insert mode, cursor after header
  → attach TextChanged/TextChangedI autocmd on buf
      first keystroke → start uv timer (100 ms tick)
  → each tick:
      recount words
      update winbar
      check thresholds
  → on BufWipeout:
      stop timer
      prompt save dialog
```

---

## Word counting

Simple, fast. Split buffer lines on whitespace, count non-empty tokens. Exclude the date header line.

```lua
local function count_words(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 1, -1, false)  -- skip line 0 (header)
  local n = 0
  for _, line in ipairs(lines) do
    for _ in line:gmatch('%S+') do n = n + 1 end
  end
  return n
end
```

---

## Winbar display

Use `vim.wo[win].winbar`. Updated every tick.

Normal state:
```
 42 words • 01:23
```

Highlight groups used:
| State | Group | Effect |
|---|---|---|
| Running (words not met) | `WsRunning` (fg = comment gray) | subtle |
| Words goal met | `WsGoalMet` (fg = yellow/gold) | warm |
| Time expired + words met | `WsDone` (fg = green) | success |
| Time expired + words NOT met | `WsOver` (fg = bright green) | encouraging |

Highlight groups defined once at module load via `vim.api.nvim_set_hl`.

---

## Threshold logic (per tick)

```
words_goal_met  = word_count >= max_words
elapsed_secs    = (vim.uv.now() - start_time) / 1000
time_expired    = elapsed_secs >= max_time

if words_goal_met and not celebration_running then
  trigger_celebration()

if time_expired then
  if words_goal_met  → switch to WsDone highlight, stop timer
  if not words_goal_met → switch to WsOver highlight (green), keep timer running
```

Wait — re-reading spec: when time expired + words met → "timer continues". Interpreting this as: the session stays open and the timer keeps ticking (user can keep writing freely). The display just changes highlight to signal completion.

---

## Celebration ideas

Three options — pick one (or combine):

**A. Winbar pulse** (recommended, zero dependencies)
Rapidly cycle the winbar highlight through a warm sequence (yellow → orange → white → yellow) 6–8 times over ~1.5 s using a fast one-shot timer, then settle on `WsGoalMet`. Pure winbar, no buffer noise.

**B. Virtual text confetti**
Scatter a handful of `✦ ✸ ★ ✺` characters as ephemeral extmarks at random line/col positions in the visible window. Remove them after 2 s. Adds visible flair without touching actual buffer content (extmarks don't appear in `:w`).

**C. Floating congratulation window**
Open a small centered floating win (no border, 1–2 lines) showing e.g. `  goal reached ` with a distinct highlight. Auto-close after 2 s. Non-intrusive, clearly readable.

**D. mini.notify** (already installed)
Fire `vim.notify('75 words — goal reached!', vim.log.levels.INFO)` through the existing notify stack. Simple, consistent with the rest of the UI.

Recommendation: **A + D** — the pulse gives immediate visual feedback in the writing area, notify gives a readable message without interrupting flow.

---

## Close / save dialog

Triggered by `BufWipeout` autocmd (fires when buffer is truly destroyed, e.g. `:bwipeout`, `q`, window close).

```lua
vim.ui.select(
  { 'Save to default path', 'Save to custom path', 'Discard' },
  { prompt = 'Save writing session?' },
  function(choice) ... end
)
```

Default path: `~/Dropbox/memex/daily.journal.YYYY.MM.DD.md`

If file already exists: append with a `---` separator + new date+time heading, do not overwrite.

Edge case: if buffer is empty (only the date header), skip the dialog and just close.

---

## Help doc

A vimdoc-format help file lives alongside the plugin at:

```
doc/writing-session.txt
```

Content drawn from the 750words.com philosophy and Julia Cameron's *Morning Pages* concept:

**Structure**:

```
*writing-session.txt*   A daily writing practice for Neovim

INTRODUCTION                                    *writing-session*

750 words is the "online, future-ified, fun-ified translation of Morning Pages" —
a daily writing practice of three longhand pages (~750 words) described by Julia
Cameron in The Artist's Way. The goal is not to write well. The goal is to write
without censoring, editing, or perfecting. Get everything out of your head and
onto the page every morning, and the rest of the day opens up.

This plugin brings that practice into Neovim:
  - one command, one scratch buffer, one date header
  - a gentle timer and word counter, never intrusive
  - no spell-check, no linting, no judgment
  - saves into your memex when you close

USAGE                                           *writing-session-usage*

  :WritingSession [max_words=N] [max_time=S]

  Opens a dated scratch buffer. Start typing to start the timer.
  The winbar shows  42 words • 01:23  at all times.
  Hit the word goal and a small celebration fires.
  Hit the time limit without hitting the goal and the display turns green:
  keep going, there is no failure here.
  Close the buffer and you will be asked whether to save.

CONFIGURATION                                   *writing-session-config*

  Defaults (set in writing_session.setup or override per-invocation):

  max_words          75       word goal per session
  max_time           120      seconds before timer turns green
  save_dir           ~/Dropbox/memex/
  filename_pattern   daily.journal.YYYY.MM.DD.md

HIGHLIGHTS                                      *writing-session-highlights*

  WsRunning    Winbar while timer is running and goal not yet met
  WsGoalMet    Winbar after word goal is reached
  WsDone       Winbar when time expired and goal was met
  WsOver       Winbar when time expired but goal was NOT met (bright green)

PHILOSOPHY                                      *writing-session-philosophy*

  "Morning pages are three pages of longhand, stream-of-consciousness writing,
  done first thing in the morning. There is no wrong way to do morning pages."
                                                — Julia Cameron, The Artist's Way

  750 words ≈ 3 pages × 250 words per page.
  Writing clears mental clutter. It is not about producing good writing.
  It is about the daily act of emptying your head so that creative work
  can follow.

  Start small. The timer is a gentle nudge, not a deadline.

vim:tw=78:ts=8:ft=help:norl:
```

---

## Open questions for the user

1. **Celebration**: prefer A+D (winbar pulse + notify), B (confetti), or C (float)?
2. **Timer-after-goal**: once max_time expires and words ARE met — should the timer stop entirely, or keep the session open for unlimited continued writing?
3. **Command name**: `:WritingSession` or something shorter like `:Write` / `:Journal`?
4. **Winbar vs statusline**: winbar is per-window (cleaner for scratch). OK to use winbar?
5. **Append vs overwrite**: for the save path, appending to an existing daily file makes sense as a journal pattern — confirm?
