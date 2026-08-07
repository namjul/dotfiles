---
description: Trace causal relations for a code artifact, behavior, or symptom — read-only
---

Trace the **causal manifold** for the subject: what fields, commits, wiring, and paths connect the starting point to the observed outcome. Explain *why* it is the way it is — not how to change it. For evidenced root-cause before fixing, load the `investigate` skill instead.

Failures and type errors are common triggers, but the same frame applies to design questions: why a field exists, why an import landed here, what commits introduced a dependency, how a behavior emerges from layers below.

## Input

$ARGUMENTS

Establish from the input (or ask if missing):

- **Starting point** — file:line, symbol, command, behavior, or symptom
- **Observed outcome** — error output, surprising behavior, or the question to answer (e.g. "why does X depend on Y?")
- **Scope** — repo path if not the current working directory

## Constraints

- **Read-only.** Do not edit source, config, lockfiles, or dependencies. Do not stage, commit, or push.
- Do not apply fixes unless explicitly asked in a follow-up.
- Separate **facts** (what you verified) from **hypotheses** (what you infer).
- Cite paths and line numbers. Use git history when imports, packages, schema, or behavior moved.

## What to trace

Distinguish three layers — they often stack:

| Layer | Question |
| ----- | -------- |
| **Immediate** | What is true at the starting point right now? (resolution, runtime behavior, type shape, call site) |
| **Structural** | What wiring connects it? (imports, package graph, config, schema, module boundaries) |
| **Feature / design** | Why was it introduced? (plan, invariant, product rule, extraction, naming contract) |

Follow the chain in both directions when useful: outcome ← mechanism ← declaration ← design intent ← commit history.

## Deliverables

1. **Observed outcome** — exact error, quoted behavior, or stated question
2. **Immediate layer** — what holds at the starting point and how the toolchain or runtime reaches it
3. **Structural layer** — wiring artifacts verified on disk (do not assume)
4. **Feature layer** — design intent, related fields, and call sites that pull the dependency in
5. **Git causal chain** — commits that introduced, moved, or renamed the relevant pieces (hash + one-line effect each)
6. **Diagram** — mermaid or ASCII from design → artifact → mechanism → outcome
7. **Bottom line** — one paragraph: application-logic explanation, wiring/environment gap, or intentional design?
8. **Re-entry** — 2–4 concrete ideas to regain traction after the trace. Pick what fits the stuck point:
   - **Research** — docs, plans, ADRs, or commits worth reading next
   - **Investigation** — a read-only probe that would collapse uncertainty (one command, one grep, one git show)
   - **Frame** — a different lens on the same facts (design vs wiring vs history)
   - **Motion** — a way of thinking that unsticks (compare/contrast, boundary draw, minimal slice, teach-back)

   Invitations to explore — not implementation steps unless the user explicitly asked for fixes.

Fixes may appear only as a one-line footnote, if at all.

## Tone

Precise and evidence-based. Proportional to complexity.
