---
name: plan
description: Research the codebase and produce a written implementation plan for a code change. Use when asked to plan, spec, or prepare implementation — after exploration is done or when the requirement is already clear. Produces minimal or comprehensive plans with verifiable outcomes. Makes no source-code changes.
---

# Plan

Research the codebase and produce an implementation plan. **Make no source-code changes.**

Favor concrete repo facts, explicit constraints, and verifiable outcomes over broad product prose. Keep plans concise. Reduce cognitive load — default to minimal unless complexity warrants more.

## Self-containment

A plan must be self-contained. Assume the reader has only the plan, with no access to the conversation that produced it. Carry enough context and rationale for a fresh agent to make good decisions: key constraints, decisions already made and why, and relevant background from research. It does not need exhaustive detail or every code location; it needs enough that a competent agent can find the rest and choose well.

**Test:** Could a fresh agent build the right thing from this plan alone?

## Research

Before planning, explore what exists:

- Read project documentation (READMEs, docs) for conventions
- Explore relevant files, adjacent files that may need to change, and existing patterns
- Check prior art and related implementations in the repo
- Review recent git history when it clarifies intent or constraints
- Understand architecture and current state of code involved

Cite real file paths in the plan. Ask a clarifying question only when a reasonable assumption would materially change scope, data model, compatibility, or user-visible behavior.

Design for **deep modules** where it matters: narrow interfaces, rich implementations. Use consistent software-design vocabulary in the plan.

## Detail level

Choose based on complexity. **Default to minimal.**

| Tier | When |
|------|------|
| **Minimal** | Simple, well-understood changes; single area of the codebase |
| **Comprehensive** | Architectural changes, multi-file features, migrations, new subsystems, or high-risk surface (public API, security, data model) |

State which tier you chose and why in one line.

## Minimal plan shape

```markdown
# <Change Name>

## Goal

<Outcome and why.>

## Context & Decisions

<Background, constraints, decisions made and why — for a fresh reader.>

## Changes

- <What to change, where (file paths), and why.>

## Tests

- <Tests to add or update.>

## Docs

- <Docs to add or update, if any.>

## Skills to use

- `<skill-name>` — <when during implementation>

## Acceptance

- <Deterministic checks; include at least one runnable verification command.>

Verification:

- `<exact command>`
```

## Comprehensive plan shape

```markdown
# <Feature Or Project Name>

## Goal

<Outcome, why it exists, implementation strategy.>

## Context & Decisions

<Background from research and exploration. Decisions made, alternatives considered, why this path.>

## Current State

- <Concrete repo fact with file path.>
- <Existing behavior, gap, or dependency.>

## Non-Negotiables

- <Compatibility, security, performance, UX, testing constraint.>
- <Explicit out-of-scope item.>

## Technical Approach

<Design with alternatives considered. Use sections like Data Model, API, CLI, Storage, Config, Error Handling, Migration as needed. Include types or signatures when implementation depends on them.>

## System Impact

<What else is affected; error propagation; state risks.>

## Implementation Slices

### Slice 1: <Narrow deliverable>

- <Task.>

Verification:

- `<exact command>`

Review:

<What a fresh read-only reviewer should check against this slice.>

### Slice 2: <Next deliverable>

...

## Test Strategy

<Kinds of tests, new paths, edge cases.>

## Documentation Strategy

<What docs change and when.>

## Skills to use

- `<skill-name>` — <when during implementation>

## Risks & Mitigations

- <Risk> — <mitigation>

## Future Work

<Ideas explicitly out of first pass.>

## Open Questions

- <Question with default recommendation when possible.>
```

Each implementation slice must be small enough to review independently. Prefer bullets over long prose.

## Writing rules

- Every major claim should name a file, define behavior, constrain scope, or describe verification.
- Use precise modal language: "must", "do not", "default to", "leave out of first pass".
- Avoid generic acceptance criteria like "works correctly" — use deterministic checks or commands.
- Separate first-pass work from future enhancements.
- Include failure modes and edge cases when they define behavior.
- For "Skills to use", list skills available in context by name with a one-line note on when they apply during implementation.

## Adversarial review

**Comprehensive plans:** Before any slice is considered done during implementation, a fresh read-only reviewer should check the diff against that slice and the plan.

**Minimal plans:** Add a Review note only when the change touches public API, migrations, security, or shared infrastructure.

## Output

Present the plan in your response. If the user asked to save it, write to the requested path. Otherwise return the plan body only.
