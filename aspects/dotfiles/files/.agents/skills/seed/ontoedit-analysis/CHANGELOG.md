# OntoEdit analysis skill — rubric changelog

## 9.17 — 2026-09-20

- Initial import from OntoEdit DB dashboard export into `resources/rubric-pack.md`.
- Skill contract: `SKILL.md`, `resources/report-schema.md`.

### Upgrade procedure

1. Add or replace `resources/rubric-pack.md` (or add `rubric-pack-vNN.md` and point the skill default in `SKILL.md` if breaking).
2. Bump `rubricVersion` in rubric front matter.
3. Record changes here; retain prior rubric file when reports must stay reproducible.
