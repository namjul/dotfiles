---
name: codebase-walkthrough
description: Guide the user through a codebase proximal-to-distal using Shannon/Neovim annotations, pausing for inquiry between modules
activation:
  - when the user asks to walk through a codebase
  - when the user wants to understand an unfamiliar project
  - when the user wants a guided tour of code they own
tags:
  - codebase
  - walkthrough
  - shannon
  - neovim
  - learning
---

# Codebase Walkthrough

## Purpose

Walk the user through a codebase along a proximal-to-distal axis — starting from the vocabulary and types that give the system its language, moving outward through logic and derivation, to the rendering or output shell. Each stop opens the file in Neovim via Shannon, annotates load-bearing lines, and pauses for inquiry before moving on.

---

## Proximal-to-Distal Axis

Proximal = closest to intent and meaning (types, vocabulary, schema)
Distal = furthest from intent (rendering, effects, output)

Typical formation order:

1. **Types / Vocabulary** — the language the system speaks; domain concepts as data shapes
2. **Geometry / Math** — pure functions on that data; no side effects
3. **Schema / Persistence** — how data is stored and what the DB knows
4. **Derivation / Query** — pure transformation from stored to display state
5. **Reactive Bridge** — how persistence talks to the UI framework's signal system
6. **Interaction / Intent** — pure state machine; no DB access
7. **Commitment / Writes** — reads intent, writes to DB, applies inverses
8. **Wiring / App** — joins all three; no logic of its own
9. **Rendering / Shell** — consumes display state; draws or emits

---

## Success Criteria

Before starting, verify:

- ✅ All source files read and formation order established
- ✅ Each file opened in Neovim via Shannon before being discussed
- ✅ Load-bearing lines annotated (not every line — only the ones that carry conceptual weight)
- ✅ Pause after each file for user inquiry before advancing
- ✅ TODOs surfaced during inquiry tracked and offered for colocated placement at end

---

## Protocol

### Step 1 — Survey

Read the project structure. Identify all source files. Do not open Neovim yet. Establish the formation order and state it to the user as a numbered list.

Ask: "Does this order look right? Any files to add or skip?"

### Step 2 — Walk

For each file in formation order:

1. Open the file in Neovim via Shannon (`wincent.shannon.private.open`)
2. Read the file
3. Annotate 3–7 load-bearing lines — lines that carry conceptual weight, encode a non-obvious invariant, or represent a decision point. Use `wincent.shannon.private.annotate`. Place annotation **above** the target line.
4. Say: "Open in Neovim. [One sentence on what this file does in the system.]"
5. **Stop and wait.** Do not advance until the user says "next" or equivalent.

During inquiry pauses:
- Answer questions directly and concisely
- If the user surfaces a TODO or design concern, note it internally
- Do not volunteer additional annotations unless asked

### Step 3 — Wrap

After the last file:

1. List all TODOs surfaced during the walkthrough
2. Offer: "Want me to place these as colocated TODO comments in the code?"
3. Offer: "Want me to write the annotations as inline documentation comments?"

---

## Shannon RPC Commands

Open file in Neovim:
```
nvim --server $NVIM --remote-expr 'luaeval("require(\"wincent.shannon.private\").open([[<abs-path>]])")'
```

Annotate a line (place annotation above line N):
```
nvim --server $NVIM --remote-expr 'luaeval("require(\"wincent.shannon.private\").annotate([[<abs-path>]], <line>, [[<annotation-text>]])")'
```

Jump to a line:
```
nvim --server $NVIM --remote-expr 'luaeval("require(\"wincent.shannon.private\").jump([[<abs-path>]], <line>)")'
```

Clear all marks:
```
nvim --server $NVIM --remote-expr 'luaeval("require(\"wincent.shannon\").ShannonClearMarks()")'
```

`$NVIM` is the socket address of the running Neovim instance. Read it from the environment or ask the user to provide it.

**Important:** Always read the file first (with Read tool) and use `grep -n` to get exact line numbers before annotating. Never estimate line numbers from memory.

---

## Annotation Principles

- Annotate **invariants**: things that must be true for the system to work (e.g. "null = root place, non-null = child")
- Annotate **dual semantics**: same field, different meaning depending on context
- Annotate **join points**: where two independent concerns meet
- Annotate **non-obvious decisions**: why this shape, not another
- Skip obvious things: loop variables, standard library calls, getter/setter patterns

Aim for 3–7 annotations per file. More is noise.

---

## Forbidden Behavior

- Do not advance to the next file without waiting for "next"
- Do not annotate every line
- Do not explain the entire codebase upfront
- Do not estimate line numbers — always verify with Read or grep
- Do not surface TODOs as inline comments during the walk — collect them, place them only if asked at the end
