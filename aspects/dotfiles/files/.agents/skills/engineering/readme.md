# Engineering craft pocket

Aim → Hammond skill. Load the skill named in the row. This is craft navigation, not worldview.

## Spine (default change path)

```text
specification → story-splitting → planning
  → tdd + testing → (refactoring | reduce-system-complexity)
  → technical-writing | expectations
  → stack-pull-requests when the PR itself is too big
```

## Pocket (~12)

| Aim | Load |
| --- | --- |
| Fuzzy intent; no rules/examples yet | `specification` |
| Artifact exists; poke holes | `find-gaps` |
| Epic too big; need vertical slices | `story-splitting` |
| PR-sized plan for agreed work | `planning` |
| One slice too large; stack PRs | `stack-pull-requests` |
| New/changed observable behavior | `tdd` → then `testing` |
| UI / browser behavior evidence | `front-end-testing` |
| Legacy: pin current behavior first | `characterisation-tests` |
| Untestable deps; need seams | `finding-seams` |
| Clean up after green baseline | `refactoring` |
| Fewer mechanisms, same behavior | `reduce-system-complexity` |
| Gotcha / pattern while fresh | `expectations` |
| Docs that claim behavior | `technical-writing` |

## More aims

### Before motion

| Aim | Load |
| --- | --- |
| Multi-screen UX; audit mocks | `storyboard` |
| Shared language / glossary drift | `ubiquitous-language` |
| Decision tree, no artifact yet | `explore-design-space` (local, not Hammond) |
| Thin plan-only writeup | `plan` (local; keep distinct from `planning`) |

### Change / evidence

| Aim | Load |
| --- | --- |
| How to write/structure tests | `testing` |
| React component test patterns | `react-testing` |
| Are tests actually protecting? | `test-design-reviewer` |
| Visual companion to docs | `diagrams` |

### Reshape internals

| Aim | Load |
| --- | --- |
| Where architecture investment pays | `improve-codebase-architecture` |
| One module’s contract / depth | `codebase-design` |
| Folders / package layout | `structure-codebase` |
| Adopt vs build a dependency | `evaluate-existing-solutions` |

### Stack-shaped

| Aim | Load |
| --- | --- |
| Public HTTP/API contract | `api-design` |
| CLI surface | `cli-design` |
| Env/process/deploy shape | `twelve-factor` |
| Logs/traces/SLOs | `observability` |
| CI red / local≠CI | `ci-debugging` |
| TS types / schema-at-boundary | `typescript-strict` |
| Immutability / pure transforms | `functional` |

### After motion (residue)

| Aim | Where it lives |
| --- | --- |
| Behavior that cohered | the green **tests** (`tdd` / `testing`) |
| Selective learning / ADR path | `expectations` |
| Prose with receipts | `technical-writing` |

No whole-app capability catalog. Plans are deleted when done; residue stays in tests, `CLAUDE.md`/companions, and ADRs when earned.

## Not here

- **AP worldview** (explore until falsifiable, gesture/contact) → `/ap` + `attractor-protocol` (AP↔craft mapping comes later)
- **`mutation-testing`** → Hammond has it; not vendored in this tree yet
