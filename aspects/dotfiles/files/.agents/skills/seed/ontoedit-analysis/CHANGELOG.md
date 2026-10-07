# OntoEdit analysis skill — rubric changelog

## Behavior — OEST tutor as default

- Default mode is the Socratic tutor in `resources/tutor.md` (one question, rubric backstage, claimed vs earned private).
- A rubric report still runs on an explicit analysis ask, a named scope, or `full report`.
- Missing rubric pack: the tutor uses the condensed lens and says so once. A report still stops with `RUBRIC_NOT_LOADED`.

## 9.17 — 2026-09-20

- Initial import from OntoEdit DB dashboard export into `resources/rubric-pack.md`.
- Skill contract: `SKILL.md`, `resources/report-schema.md`.

### Upgrade procedure

1. Add or replace `resources/rubric-pack.md` (or add `rubric-pack-vNN.md` and point the skill default in `SKILL.md` if breaking).
2. Bump `rubricVersion` in rubric front matter.
3. Record changes here; retain prior rubric file when reports must stay reproducible.
