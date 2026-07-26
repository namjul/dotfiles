---
description: Generate orthogonal design variants before committing
---

Enumerate design variants for the subject. The goal is a navigable menu, not a recommendation monologue.

## Inputs

$ARGUMENTS

Establish from the input above (or ask if missing):

- **Subject**: what is being varied (table shape, type definition, folder layout, naming scheme, taxonomy, convention, …)
- **Baseline**: current or assumed design, if any
- **Constraints**: locked decisions, things ruled out, evaluation criteria if stated
- **Count**: default 10 for technical/schema; 5 for naming/taxonomy/process unless specified

Read referenced files or context before generating. Do not invent a baseline.

## Generation rules

- Produce exactly N variants (or N±1 if the design space genuinely has fewer distinct axes).
- Each variant must differ on a **real design axis**, not wording. Spread across the space: minimal↔maximal, flat↔nested, strict↔open, surrogate↔natural key, etc.
- Name each variant with a **short label** (3–6 words).
- Per variant: mechanism (what changes, how it behaves). Add pros/cons or a snippet only when it clarifies the distinction.
- Do **not** implement, migrate, or pick a winner unless asked.
- End with a **lean note**: which 2–3 variants merit deeper comparison given stated constraints — one short paragraph, no ranking table unless requested.

## Output shape

1. **Baseline** (1–2 sentences, if applicable)
2. **N variants** — numbered, bold label, then mechanism
3. **Lean** — which to explore next and why

## Follow-ups (only when asked)

- Deep-dive one variant (schema, types, file layout)
- Comparison table against criteria or known issues
- Recall or restate a prior variant set from the conversation
