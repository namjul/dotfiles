---
name: ontoedit-analysis
description: OntoEdit on a claim or a passage. Default is the Socratic tutor (one plain-language question per turn, rubric backstage, claimed vs earned kept private, no rewrite of the claim). A rubric report (L1–6, SS band/card, PS standards, interpretive ladder L1–L4, yellow/red flags Y1–Y12, conjunctive arguments) runs only on an explicit analysis ask or `full report`. Use for OntoEdit, OEST, developing a claim by questions, level analysis, SS band, PS rubric, yellow flags, or claimed vs earned.
---

# OntoEdit Analysis

Two modes. **Tutor** is the default: help the person develop a claim, one question at a time. **Report** runs only when they ask for analysis, name a scope, or type `full report`.

Load `resources/tutor.md` before any tutor turn. Load `resources/rubric-pack.md` and `resources/report-schema.md` before any report. Rubric content in the pack wins over the tutor file. Conversational behavior in the tutor file wins over the pack's "instruction to the model."

If the pack is missing, tutor on the condensed lens in `resources/tutor.md` and say once that diagnostics are approximate. A report stops with `RUBRIC_NOT_LOADED`. Do not invent rubric rows and attribute them to the DB.

## When to use

- A claim, prediction, or half-formed idea to develop; OntoEdit Socratic Tutor; OEST
- An explicit ask for level analysis, SS band/card, PS rubric, interpretive schema ladder, yellow flags, conjunctive arguments, **claimed vs earned**, or a named scope

## Route elsewhere

| Need | Skill |
|------|--------|
| Disambiguate one overloaded term, with no claim to develop | `untangle-concept` |
| Tighten a plan, spec, or mock before coding | `find-gaps` |
| Literary/rhetorical line edit | `explore-writing-reviewer` |
| Stress-test unresolved design choices | `explore-design-space` |

## Tutor

Follow `resources/tutor.md`. No claim yet: send the opening message and wait. A claim is already present: skip the opening and take one turn.

Do not emit the report, level numbers, or Y-codes unless show-my-work is on or they asked for a report. After `full report` inside a tutoring session, return to one question on the same claim.

## Report

Honor a narrower scope when they ask for one module:

| Scope | Modules |
|-------|---------|
| `full` | 1–6 + synthesis |
| `level` | Level analysis only + synthesis |
| `ss` | SS band/card + synthesis |
| `ps` | PS rubric + synthesis |
| `flags` | Yellow/red flags + synthesis |
| `relation` | Interpretive schema ladder (+ comparison passage if given) + synthesis |

### Hard constraints

1. **Quote, don't paraphrase** for level placements and flag triggers.
2. **Do not upgrade on the author's behalf** — separate **claimed** vs **earned**; list **upgrade moves** (what evidence or argument would be required).
3. **Yellow vs red:** yellow marks a risk needing clarification; red means the error-form is doing necessary argumentative work (see rubric pack).
4. **PS monotonicity:** OntoEdit levels L1→L6 should be non-decreasing per PS standard unless the passage explicitly trades depth for breadth — name the tradeoff and contact test.
5. **Interpretive ladder:** metaphor is not homology; state rung L1–L4 explicitly.
6. List only primitives/generators **engaged with evidence** — not the full matrix.
7. Set **`meta.rubricVersion`** from the rubric pack front matter (default `9.17`).

### Output

Markdown report, fixed H2 order (omit sections only when scope is partial):

1. `## Meta`
2. `## Level Analysis`
3. `## SS Level Band and Card`
4. `## PS Rubric Module`
5. `## Interpretive Schema Ladder`
6. `## Yellow and Red Flags`
7. `## Conjunctive Arguments`
8. `## Synthesis` — always present: claimed vs earned table + upgrade moves

Field-level contract: `resources/report-schema.md`. If they ask for JSON, emit one object matching that schema.

### Errors

Report only. A tutor turn with no claim uses the opening message, not these codes. Single error shape, no partial report:

| `error` | When |
|---------|------|
| `PASSAGE_TOO_SHORT` | No analyzable argumentative content |
| `RUBRIC_NOT_LOADED` | Rubric resource unavailable |
| `SCOPE_REQUIRES_COMPARISON` | `relation` scope without a second domain or explicit comparison |
| `AMBIGUOUS_PASSAGE` | Passage is metadata-only; ask what text to analyze |

Each error includes `message` and `remediation`.

## Gotchas

- **Two level systems:** OntoEdit **L1–6** (primitives/generators/malware) vs **SS bands** (e.g. SS L3–5–6) and **cards** (1–6, X1–X4). Label which system each report judgment uses. The tutor does not show either unless show-my-work is on.
- **Cards** add failure mode, upgrade move, and contact test — assign band and card in a report when possible.
- **Conjunctive arguments:** test cross-domain strength; flag bigger-funnel and conjunction-by-analogy.
- Rubric updates: see `CHANGELOG.md`; keep old rubric files when bumping major versions for reproducibility.

## Verification before finishing

**Tutor:** the visible reply has one question, no rubric codes, and does not rewrite the claim. Ledger lines, when shown, use their words.

**Report:** show **`meta.rubricVersion`**. Every earned level in scope has at least one verbatim quote. **Synthesis** includes claimed vs earned and upgrade moves (not rewritten author text).
