---
name: ontoedit-analysis
description: Analyze a passage with the OntoEdit rubric pack (level analysis L1–6, SS level bands and cards, PS five standards, interpretive schema ladder L1–L4, yellow/red flags Y1–Y12, conjunctive argument types). Reports claimed vs earned levels with quotes; does not upgrade the author on their behalf. Use when the user invokes OntoEdit, asks for level analysis, SS band/card assignment, PS rubric check, yellow flags, or interpretive relation placement on a text.
---

# OntoEdit Analysis

Evaluate argumentative and ontological structure in a user-supplied passage using the pinned OntoEdit-for–social-science rubrics. The rubric definitions live in `resources/rubric-pack.md`; the normative report field names live in `resources/report-schema.md`. Load both before analyzing.

## When to use

- User names OntoEdit, level analysis, SS band/card, PS rubric, interpretive schema ladder, yellow flags, conjunctive arguments, or **claimed vs earned**
- User pastes theory, abstract, policy, or argument text for structural critique

## Route elsewhere

| Need | Skill |
|------|--------|
| Disambiguate one overloaded term | `untangle-concept` |
| Tighten a plan, spec, or mock before coding | `find-gaps` |
| Literary/rhetorical line edit | `explore-writing-reviewer` |
| Stress-test unresolved design choices | `explore-design-space` |

## Analysis scope

Default is **full** (all six modules). Honor a narrower scope when the user asks only for one module:

| Scope | Modules |
|-------|---------|
| `full` | 1–6 + synthesis |
| `level` | Level analysis only + synthesis |
| `ss` | SS band/card + synthesis |
| `ps` | PS rubric + synthesis |
| `flags` | Yellow/red flags + synthesis |
| `relation` | Interpretive schema ladder (+ comparison passage if given) + synthesis |

## Hard constraints

1. **Quote, don't paraphrase** for level placements and flag triggers.
2. **Do not upgrade on the author's behalf** — separate **claimed** vs **earned**; list **upgrade moves** (what evidence or argument would be required).
3. **Yellow vs red:** yellow marks a risk needing clarification; red means the error-form is doing necessary argumentative work (see rubric pack).
4. **PS monotonicity:** OntoEdit levels L1→L6 should be non-decreasing per PS standard unless the passage explicitly trades depth for breadth — name the tradeoff and contact test.
5. **Interpretive ladder:** metaphor is not homology; state rung L1–L4 explicitly.
6. List only primitives/generators **engaged with evidence** — not the full matrix.
7. Set **`meta.rubricVersion`** from the rubric pack front matter (default `9.17`).

## Output

Deliver a Markdown report with fixed H2 order (omit sections only when scope is partial):

1. `## Meta`
2. `## Level Analysis`
3. `## SS Level Band and Card`
4. `## PS Rubric Module`
5. `## Interpretive Schema Ladder`
6. `## Yellow and Red Flags`
7. `## Conjunctive Arguments`
8. `## Synthesis` — always present: claimed vs earned table + upgrade moves

Field-level contract: `resources/report-schema.md`.

If the user asks for JSON, emit one object matching that schema.

## Errors

When analysis cannot proceed, use a single error shape (no partial report):

| `error` | When |
|---------|------|
| `PASSAGE_TOO_SHORT` | No analyzable argumentative content |
| `RUBRIC_NOT_LOADED` | Rubric resource unavailable |
| `SCOPE_REQUIRES_COMPARISON` | `relation` scope without a second domain or explicit comparison |
| `AMBIGUOUS_PASSAGE` | Passage is metadata-only; ask what text to analyze |

Each error includes `message` and `remediation`.

## Gotchas

- **Two level systems:** OntoEdit **L1–6** (primitives/generators/malware) vs **SS bands** (e.g. SS L3–5–6) and **cards** (1–6, X1–X4) — label which system each judgment uses.
- **Cards** add failure mode, upgrade move, and contact test — assign band and card when possible.
- **Conjunctive arguments:** test cross-domain strength; flag bigger-funnel and conjunction-by-analogy.
- Rubric updates: see `CHANGELOG.md`; keep old rubric files when bumping major versions for reproducibility.

## Verification before finishing

Show **`meta.rubricVersion`** in the report. Every earned level in scope has at least one verbatim quote. **Synthesis** includes claimed vs earned and upgrade moves (not rewritten author text).
