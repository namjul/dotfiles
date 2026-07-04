# Requirements To Spec

## Overview

Turn an underspecified requirement into an implementation-ready Markdown spec. Favor concrete repo facts, explicit constraints, incremental delivery slices, and verifiable outcomes over broad product prose. Delivery slices should be small enough for human reviewer without cognitive overload. Keep the spec concise. Always include the **Implementation Slices** section. Focus on the implementation plan and the open questions reviewers can help answer. Remember to reduce cognitive load.

## Workflow

1. Restate the user requirement as a narrow implementation goal.
2. Inspect the repository when paths, modules, APIs, tests, or existing patterns matter. Cite real files in the spec and docs that needs update.
3. Ask a clarifying question only when a reasonable assumption would materially change scope, data model, compatibility, or user-visible behavior.
4. Draft the spec in Markdown using the structure below, omitting irrelevant sections and adding domain-specific ones when needed.
5. Make each implementation slice small enough to review independently and include exact verification commands.
6. Adversarial review. Before any implementation slice is checked off, a fresh read-only sub-agent/teammate reviews the diff against the todo + plan.
7. If the user asked to save the spec, write it to the requested path. Otherwise, return the spec body.

## Spec Shape

Use this default shape for opencode-style specs:

```markdown
# <Feature Or Project Name>

## Goal

<One or two paragraphs explaining the outcome, why it exists, and the implementation strategy.>

## Current State

- <Concrete repo fact with file path.>
- <Existing behavior, gap, dependency, or adjacent implementation.>

## Non-Negotiables

- <Compatibility, determinism, migration, performance, security, UX, or testing constraint.>
- <Explicit out-of-scope item when it prevents scope creep.>

## <Design Section>

<Use sections like Data Model, API And Tool Surface, CLI Behavior, TUI Behavior, Storage, Config, Error Handling, Migration, or Deterministic Checks. Include code-shaped types or endpoint/tool signatures when useful.>

## Implementation Slices

### PR 1: <Narrow Deliverable>

- <Implementation task.>
- <Implementation task.>

Verification:

- `<exact command>`
- `<exact command>`

Review:

<Use this section to outline the review process for the implementation slice.>

### PR 2: <Next Deliverable>

- <Implementation task.>

Verification:

- `<exact command>`

Review:

<Use this section to outline the review process for the implementation slice.>

## Future Work

<Optional ideas that should not be included in the first implementation.>

## Open Questions

- <Question with a default recommendation when possible.>
```

## Writing Rules

- Keep the spec actionable. Every major claim should either name a file, define behavior, constrain scope, or describe verification.
- Prefer bullets over long prose for current state, constraints, and implementation tasks.
- Use precise modal language: "must", "do not", "default to", "leave out of first pass".
- Include expected data shapes, request/response shapes, config names, or CLI/tool signatures when implementation depends on them.
- Separate first-pass requirements from future enhancements. Do not bury speculative work in the core implementation.
- Include failure modes and edge cases when they define the behavior.
- Avoid generic acceptance criteria like "works correctly". Replace them with deterministic checks or commands.
- If compatibility or generated clients are affected, call out the regeneration command in the relevant slice.
- Keep open questions few and decision-oriented. Provide a default answer when the repo context supports one.
