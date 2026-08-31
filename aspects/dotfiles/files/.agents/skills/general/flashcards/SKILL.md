---
name: flashcards
description: >
  Generate Anki-ready flashcards in memex markdown — Q./A. Basic cards and
  {cloze} deletions for anki-sync. Use when the user says "make flashcards",
  "flashcards from", "cards for this note", or invokes /flashcards.
---

Turn source material into durable recall prompts in the formats `anki-sync` already harvests. Scheduling lives in Anki; this skill only authors cards.

## Intent

- Produce cards the user can paste or insert into a memex `.md` file (often the open note). Do not invent a fixed deck path or run a chat drill/Leitner loop.
- Prefer fewer precise cards over many weak ones. One atomic fact or distinction per card.
- Prefer cloze when the prompt is a natural sentence with a critical gap; prefer `Q.`/`A.` when the answer is a definition, name, list, or short rule that does not sit cleanly in prose.
- Stay faithful to the source. If a claim is not in the source and confidence is low, omit it or mark `[VERIFY]` on that card only.

## Output formats (must match anki-sync)

Cards are ordinary paragraphs — never inside fenced code, list items, or headings (those node types are ignored by the sync parser).

**Basic — one line each; optional blank line between:**

```
Q. What is the default HTTP port?
A. 80.
```

**Cloze — brace the deleted span in flowing prose; multiple `{…}` in one paragraph become separate cards:**

```
Spaced repetition schedules the next review based on {retrieval strength}, not calendar habit.
```

Hard constraints the parser enforces:

- `Q.` and `A.` lines are single-line only; no multiline fronts or backs.
- After a `Q.` paragraph, the next non-blank line must be `A.`; otherwise the pair is skipped.
- Cloze uses single braces `{deleted text}` in source; sync rewrites to Anki `{{cN::…}}`. Do not emit Anki's double-brace syntax in the markdown.
- Braces inside `` `inline code` `` are not cloze — avoid accidental `{…}` there.
- Identical card text across files shares a GUID and overwrites on import; do not duplicate the same prompt.

Full sync rules live in `bin/anki-sync.md` (this repo) if a format edge case is unclear.

## Card quality

- Front (or cloze sentence) should cue one answer without leaking it.
- Back should be the minimal correct recall — no essay.
- Avoid yes/no, trivia without a use, and cards that only make sense if the note is open.
- When the source already has cards, extend rather than rewrite unless asked.

## Delivery

Emit the cards as markdown ready to land in the target note. Write into a file only when the user names one or clearly wants the open buffer updated; otherwise show the block and stop.
